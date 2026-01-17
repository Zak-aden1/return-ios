// Supabase Edge Function for ImanPath Coach
// Proxies requests to Anthropic API with server-side API key

import "jsr:@supabase/functions-js/edge-runtime.d.ts"

const ANTHROPIC_API_URL = "https://api.anthropic.com/v1/messages"
const MODEL = "claude-sonnet-4-20250514"
const MAX_TOKENS = 1024

// CORS headers for iOS app
const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
}

// System prompt builder
function buildSystemPrompt(dataPack: string): string {
  return `You are Streak Coach, a compassionate companion for someone on their recovery journey from pornography addiction. You are part of ImanPath, an Islamic recovery app.

## Your Role
- Ground every response in the user's actual data (provided below)
- Reference specific entries using the citation IDs provided
- Always end with ONE concrete action they can take right now
- Adjust your tone based on their streak day
- Provide Islamic perspective naturally, not forcefully

## Tone by Streak Stage
- Day 0-3: Gentle, stabilizing. "One moment at a time. You're here, that's what matters."
- Day 4-14: Encouraging, pattern-aware. "You're building momentum. I notice..."
- Day 15-30: Reinforcing growth. "Look how far you've come. Your milestone is close."
- Day 30+: Identity affirmation. "This is who you are now. A person of strength."

## Response Rules
1. Keep responses concise (2-3 short paragraphs max)
2. Cite specific data using the IDs like [journal:abc12345] or [checkin:2026-01-10]
3. End with ONE action suggestion
4. Include brief Islamic encouragement if natural (verse or reminder)
5. NEVER fabricate data - only reference what's in the context
6. If user shows signs of crisis, include: "If you're in crisis, please reach out to a mental health professional."

## Actions You Can Suggest
- breathing: 4-7-8 breathing exercise
- journal: Write in journal
- checkin: Do daily check-in
- panic: Open panic button tools
- dua: Read duas for strength
- none: No specific action needed

## Required Response Format
You MUST respond with valid JSON only. Do not include any text before or after the JSON:
{
  "reply": "Your message here with natural citation references",
  "citations": ["journal:abc12345", "checkin:2026-01-10"],
  "suggestedAction": "breathing"
}

## User's Current Data
${dataPack}`
}

// Parse Claude's response (handle markdown code blocks)
function parseCoachResponse(text: string): { reply: string; citations: string[]; suggestedAction: string | null } {
  let cleanedText = text.trim()

  // Remove markdown code blocks if present
  if (cleanedText.startsWith("```json")) {
    cleanedText = cleanedText.slice(7)
  } else if (cleanedText.startsWith("```")) {
    cleanedText = cleanedText.slice(3)
  }
  if (cleanedText.endsWith("```")) {
    cleanedText = cleanedText.slice(0, -3)
  }
  cleanedText = cleanedText.trim()

  return JSON.parse(cleanedText)
}

Deno.serve(async (req) => {
  // Handle CORS preflight
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders })
  }

  try {
    // Get API key from secrets
    const apiKey = Deno.env.get("ANTHROPIC_API_KEY")
    if (!apiKey) {
      console.error("ANTHROPIC_API_KEY not configured in secrets")
      return new Response(
        JSON.stringify({ error: "API key not configured" }),
        { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      )
    }

    // Parse request body
    const { messages, dataPack, userMessage } = await req.json()

    if (!userMessage || !dataPack) {
      return new Response(
        JSON.stringify({ error: "Missing required fields: userMessage, dataPack" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      )
    }

    // Build messages array for Anthropic
    const anthropicMessages = [
      // Add conversation history
      ...(messages || []).map((msg: { role: string; content: string }) => ({
        role: msg.role,
        content: msg.content,
      })),
      // Add current user message
      { role: "user", content: userMessage },
    ]

    // Build request body for Anthropic
    const requestBody = {
      model: MODEL,
      max_tokens: MAX_TOKENS,
      system: buildSystemPrompt(dataPack),
      messages: anthropicMessages,
    }

    console.log("Calling Anthropic API...")

    // Call Anthropic API
    const anthropicResponse = await fetch(ANTHROPIC_API_URL, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "x-api-key": apiKey,
        "anthropic-version": "2023-06-01",
      },
      body: JSON.stringify(requestBody),
    })

    // Handle rate limiting from Anthropic
    if (anthropicResponse.status === 429) {
      return new Response(
        JSON.stringify({ error: "rate_limit", message: "Rate limit exceeded. Please try again later." }),
        { status: 429, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      )
    }

    // Handle other errors from Anthropic
    if (!anthropicResponse.ok) {
      const errorBody = await anthropicResponse.text()
      console.error("Anthropic API error:", anthropicResponse.status, errorBody)
      return new Response(
        JSON.stringify({ error: "api_error", message: `Anthropic API error: ${anthropicResponse.status}` }),
        { status: anthropicResponse.status, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      )
    }

    // Parse Anthropic response
    const anthropicData = await anthropicResponse.json()
    const text = anthropicData.content?.[0]?.text

    if (!text) {
      console.error("No text in Anthropic response:", anthropicData)
      return new Response(
        JSON.stringify({ error: "invalid_response", message: "No text in Anthropic response" }),
        { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      )
    }

    // Parse the JSON response from Claude
    const coachResponse = parseCoachResponse(text)

    console.log("Successfully processed coach request")

    // Return success response
    return new Response(
      JSON.stringify(coachResponse),
      { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    )

  } catch (error) {
    console.error("Edge function error:", error)
    return new Response(
      JSON.stringify({ error: "server_error", message: error.message }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    )
  }
})
