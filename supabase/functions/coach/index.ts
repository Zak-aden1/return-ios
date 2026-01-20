// Supabase Edge Function for ImanPath Coach
// Proxies requests to Anthropic API with streaming support

import "jsr:@supabase/functions-js/edge-runtime.d.ts"

const ANTHROPIC_API_URL = "https://api.anthropic.com/v1/messages"
const MODEL = "claude-sonnet-4-20250514"
const MAX_TOKENS = 1024

// CORS headers for iOS app
const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
}

// System prompt builder (simplified for streaming - plain text response)
function buildSystemPrompt(dataPack: string): string {
  return `You are Streak Coach, a compassionate companion for Muslims recovering from pornography addiction. Part of Return, an Islamic recovery app.

## Response Format (CRITICAL - this is a mobile chat app)
- Maximum 2 paragraphs, 2-3 sentences each
- Weave action suggestions into your final sentence naturally (not as a separate section)
- Include Quranic verses only ~30% of the time, not every message
- Total response must fit on one mobile screen without scrolling

## Tone by Streak Stage
- Day 0-3: Gentle. "One moment at a time."
- Day 4-14: Encouraging. "You're building momentum."
- Day 15-30: Reinforcing. "Look how far you've come."
- Day 30+: Affirming. "This is who you are now."

## Rules
- Only reference data provided below - never fabricate
- Crisis signs → add: "If you're in crisis, please reach out to a mental health professional."
- Plain text only, conversational style

## USER'S DATA
${dataPack}`
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
    const { messages, dataPack, userMessage, stream } = await req.json()

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
      stream: stream === true, // Enable streaming if requested
    }

    console.log(`Calling Anthropic API (stream: ${stream === true})...`)

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

    // If streaming, pass through the SSE response
    if (stream === true) {
      return new Response(anthropicResponse.body, {
        status: 200,
        headers: {
          ...corsHeaders,
          "Content-Type": "text/event-stream",
          "Cache-Control": "no-cache",
          "Connection": "keep-alive",
        },
      })
    }

    // Non-streaming: parse and return full response
    const anthropicData = await anthropicResponse.json()
    const text = anthropicData.content?.[0]?.text

    if (!text) {
      console.error("No text in Anthropic response:", anthropicData)
      return new Response(
        JSON.stringify({ error: "invalid_response", message: "No text in Anthropic response" }),
        { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      )
    }

    console.log("Successfully processed coach request")

    // Return plain text response wrapped in simple JSON
    return new Response(
      JSON.stringify({ reply: text }),
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
