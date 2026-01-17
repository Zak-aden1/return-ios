//
//  LessonContent.swift
//  ImanPath
//
//  Static lesson content data structure
//

import Foundation

struct LessonContent: Identifiable {
    let id: Int  // Day number (1-30)
    let title: String
    let verse: String
    let verseTranslation: String
    let verseReference: String
    let content: String
    let reflection: String
    let readTimeMinutes: Int

    var day: Int { id }
}

// MARK: - All Lessons Data

extension LessonContent {
    static let allLessons: [LessonContent] = [
        // Day 1
        LessonContent(
            id: 1,
            title: "Your New Beginning",
            verse: "قُلْ يَا عِبَادِيَ الَّذِينَ أَسْرَفُوا عَلَىٰ أَنفُسِهِمْ لَا تَقْنَطُوا مِن رَّحْمَةِ اللَّهِ",
            verseTranslation: "Say, 'O My servants who have transgressed against themselves, do not despair of the mercy of Allah. Indeed, Allah forgives all sins. Indeed, it is He who is the Forgiving, the Merciful.'",
            verseReference: "Quran 39:53",
            content: """
Today marks the beginning of something meaningful. Not just another attempt, but a conscious choice to reclaim your life, your peace, and your connection with Allah.

You might be carrying shame from past failures. You might wonder if this time will be different. These feelings are natural, but they don't define your journey ahead.

Here's what you need to understand: Allah's mercy is greater than any sin you've committed. The very fact that you're here, seeking change, is a sign of His guidance. He hasn't given up on you, so don't give up on yourself.

This isn't about willpower alone. Research shows that addiction creates neural pathways in the brain that take time to rewire. The first days are often the hardest because your brain is adjusting. This is biology, not weakness.

Over the next 30 days, you'll learn:
• How addiction works in the brain and spirit
• Practical strategies to manage triggers and urges
• Islamic teachings that provide protection and healing
• How to build habits that support your recovery

Some days will be harder than others. That's expected. What matters isn't perfection—it's persistence. Every time you choose to stay on this path, you're building something stronger.

The Prophet ﷺ said: "Every son of Adam sins, and the best of those who sin are those who repent." You're not defined by your falls, but by your rising.

Today's goal is simple: Be here. Acknowledge where you are. And trust that the path forward exists.
""",
            reflection: "What brought you to this moment? What do you hope to feel in 30 days that you don't feel today?",
            readTimeMinutes: 3
        ),

        // Day 2
        LessonContent(
            id: 2,
            title: "Understanding Addiction",
            verse: "إِنَّ النَّفْسَ لَأَمَّارَةٌ بِالسُّوءِ إِلَّا مَا رَحِمَ رَبِّي",
            verseTranslation: "Indeed, the soul is a persistent enjoiner of evil, except those upon which my Lord has mercy.",
            verseReference: "Quran 12:53",
            content: """
To overcome something, you must first understand it. Today, we look at what's actually happening when addiction takes hold.

Your brain has a reward system designed to reinforce behaviors necessary for survival. When you eat, connect with others, or achieve something, your brain releases dopamine—a chemical that creates feelings of pleasure and motivation.

Pornography hijacks this system. It floods your brain with dopamine levels far beyond what natural experiences provide. Over time, your brain adapts by reducing its sensitivity. This means you need more stimulation to feel the same effect, while everyday pleasures become less satisfying.

This is why recovery often feels flat at first. Your brain's reward system needs time to recalibrate. This period—sometimes called "flatline"—is actually healing in progress.

The Quran recognized the soul's tendency toward harmful desires 1400 years before neuroscience confirmed it. The "nafs" (soul/self) that enjoins evil isn't a character flaw—it's a reality every human faces. But notice the exception: "except those upon which my Lord has mercy."

This means change is possible. Your brain can heal. New pathways can form. The mercy of Allah works through both spiritual and physical means.

Understanding this removes shame and replaces it with strategy. You're not fighting against your character—you're rewiring your brain while purifying your soul. Both take time. Both are happening with every day you stay committed.
""",
            reflection: "How has this addiction affected your ability to enjoy simple, everyday moments?",
            readTimeMinutes: 3
        ),

        // Day 3
        LessonContent(
            id: 3,
            title: "The Power of Intention",
            verse: "وَالَّذِينَ جَاهَدُوا فِينَا لَنَهْدِيَنَّهُمْ سُبُلَنَا",
            verseTranslation: "And those who strive for Us—We will surely guide them to Our ways. And indeed, Allah is with the doers of good.",
            verseReference: "Quran 29:69",
            content: """
In Islam, every action begins with intention. The Prophet ﷺ said: "Actions are judged by intentions, and everyone will be rewarded according to what they intended."

Your intention isn't just a mental note—it's the foundation that determines the nature of your entire journey. Are you quitting because you're tired of guilt? Because you want to be a better Muslim? Because you want mental clarity? Because you want a healthier marriage?

All of these are valid. But the deeper your intention connects to your purpose in life, the stronger your resolve becomes.

Consider framing your intention around these levels:

Personal: "I want to reclaim my mental clarity and self-respect."

Relational: "I want to be fully present for my family and future spouse."

Spiritual: "I want to stand before Allah in prayer without the weight of this sin."

Purpose: "I want to fulfill my potential as a servant of Allah and benefit others."

When urges come—and they will—your intention is your anchor. It reminds you why temporary discomfort is worth long-term freedom.

Write your intention down. Make it specific. Make it personal. The verse above promises that those who strive sincerely will be guided. Allah doesn't ask for perfection—He asks for genuine effort in His direction.

Your intention transforms this from "giving something up" to "building something greater."
""",
            reflection: "Write down your primary intention for this journey. Why does this matter to you at the deepest level?",
            readTimeMinutes: 3
        ),

        // Day 4
        LessonContent(
            id: 4,
            title: "Identifying Your Triggers",
            verse: "الشَّيْطَانُ يَعِدُكُمُ الْفَقْرَ وَيَأْمُرُكُم بِالْفَحْشَاءِ",
            verseTranslation: "Satan threatens you with poverty and orders you to immorality, while Allah promises you forgiveness from Him and bounty.",
            verseReference: "Quran 2:268",
            content: """
Every relapse has a pathway. Understanding yours is essential for prevention.

Triggers fall into several categories:

Emotional: Stress, loneliness, boredom, anxiety, sadness, even celebration. Strong emotions—positive or negative—can activate the urge to escape or reward yourself.

Environmental: Being alone with a device, certain times of day, specific locations, staying up late, being in bed with your phone.

Physical: Lack of sleep, hunger, physical exhaustion, illness. When your body is depleted, your defenses weaken.

Social: Rejection, conflict, feeling misunderstood, isolation. Humans are wired for connection, and its absence creates vulnerability.

Digital: Social media, certain apps, algorithmic suggestions, even innocent browsing that leads somewhere else.

Satan's strategy isn't usually a direct assault. It's a series of small steps that seem harmless until you're already struggling. He "orders immorality" through a chain: a thought, a glance, a click, a rationalization.

Start mapping your patterns:
• When do urges typically hit? (Time of day)
• Where are you usually? (Location)
• What were you feeling before? (Emotion)
• What were you doing? (Activity)

You'll likely notice patterns. Late nights. After arguments. When bored and alone. These aren't random—they're predictable.

Once you know your triggers, you can build barriers. Not through willpower in the moment, but through preparation before the moment arrives.
""",
            reflection: "Think about your last three relapses. What patterns do you notice in timing, location, emotion, or activity?",
            readTimeMinutes: 3
        ),

        // Day 5
        LessonContent(
            id: 5,
            title: "The Role of Environment",
            verse: "وَاصْبِرْ نَفْسَكَ مَعَ الَّذِينَ يَدْعُونَ رَبَّهُم بِالْغَدَاةِ وَالْعَشِيِّ يُرِيدُونَ وَجْهَهُ",
            verseTranslation: "And keep yourself patient with those who call upon their Lord in the morning and the evening, seeking His face.",
            verseReference: "Quran 18:28",
            content: """
You are shaped by your environment more than you realize. The spaces you inhabit, the devices you use, the content you consume—all of these influence your choices before you even make them.

This is why willpower alone fails. If you rely on saying "no" in the moment of temptation, you're fighting at your weakest point. The better strategy is designing your environment so temptation rarely reaches you.

Digital Environment:
• Remove browsers from your phone or use strict content filters
• Keep devices in public spaces, not bedrooms
• Unfollow accounts that trigger lustful thoughts (even "innocent" ones)
• Consider a basic phone for certain hours

Physical Environment:
• Don't isolate yourself when vulnerable
• Change your late-night routine—go to sleep earlier
• Exercise regularly to manage stress physically

Social Environment:
This is what the verse addresses. Surround yourself with people who remind you of Allah. Find at least one person you can be honest with about your struggle. Distance yourself from friends who normalize harmful content.

The Prophet ﷺ said: "A person is upon the religion of his close friend, so let one of you look at whom he befriends."

Your environment isn't neutral. It's either supporting your recovery or undermining it. You may not be able to change everything, but change what you can. Every barrier you build is one less battle you have to fight.
""",
            reflection: "What is one change you can make to your environment today that would reduce your exposure to triggers?",
            readTimeMinutes: 3
        ),

        // Day 6
        LessonContent(
            id: 6,
            title: "Building Your Support System",
            verse: "إِنَّمَا الْمُؤْمِنُونَ إِخْوَةٌ",
            verseTranslation: "The believers are but brothers, so make reconciliation between your brothers. And fear Allah that you may receive mercy.",
            verseReference: "Quran 49:10",
            content: """
Recovery in isolation is possible but significantly harder. Humans are designed for connection, and shame grows in secrecy while healing happens in community.

This doesn't mean you need to announce your struggle publicly. But having even one person who knows and supports you can make a profound difference.

Types of Support:

Accountability Partner: Someone who checks in on you regularly. This could be a trusted friend, sibling, or mentor. The key is honesty—they need to ask hard questions, and you need to answer truthfully.

Spiritual Guide: An imam, teacher, or mentor who can provide Islamic guidance and remind you of Allah's mercy when you forget.

Community: Being part of a masjid community, halaqah, or Islamic group. Even if they don't know your specific struggle, regular positive company elevates your spiritual state.

Professional Help: For severe cases, therapists who specialize in addiction recovery can provide tools that complement spiritual efforts.

The shame around this addiction often prevents people from seeking help. But remember: the Companions of the Prophet ﷺ came to him with their struggles, including sexual ones. He responded with wisdom, not judgment.

You don't have to share everything with everyone. But carrying this entirely alone multiplies its weight.

Consider: Who in your life could you trust with even a small part of this journey?
""",
            reflection: "Is there one person you could reach out to for support? What's holding you back from doing so?",
            readTimeMinutes: 3
        ),

        // Day 7
        LessonContent(
            id: 7,
            title: "Week 1 Reflection",
            verse: "إِنَّ اللَّهَ لَا يُغَيِّرُ مَا بِقَوْمٍ حَتَّىٰ يُغَيِّرُوا مَا بِأَنفُسِهِمْ",
            verseTranslation: "Indeed, Allah will not change the condition of a people until they change what is in themselves.",
            verseReference: "Quran 13:11",
            content: """
You've completed one week. This is significant—not because a week is long, but because you've been showing up daily, learning, and building awareness.

Let's review what you've learned:

Day 1: This journey is possible. Allah's mercy encompasses all sins. You're not defined by your past.

Day 2: Addiction is biological, not just moral. Your brain is rewiring, and the flatness you might feel is healing in progress.

Day 3: Your intention is your anchor. The deeper your "why," the stronger your resolve.

Day 4: Triggers follow patterns. Identifying them gives you power to prepare.

Day 5: Environment shapes behavior. Design your spaces to support your goals.

Day 6: Support accelerates recovery. Shame grows in isolation; healing happens in connection.

The verse today speaks to the core truth: Allah's help comes to those who initiate change within themselves. You've started that process.

This week may have been smooth or difficult. You may have had urges or felt nothing. Both are normal. What matters is that you're still here.

The coming weeks will go deeper—into spiritual protections, habit building, and emotional healing. The foundation you've built this week will support everything that follows.

Take a moment today to acknowledge your effort. Not with pride, but with gratitude. You're doing something hard, and you're doing it for the right reasons.
""",
            reflection: "What was your biggest insight from this first week? What do you want to focus on improving in week two?",
            readTimeMinutes: 3
        ),

        // Day 8
        LessonContent(
            id: 8,
            title: "Tawbah - The Door is Always Open",
            verse: "يَا أَيُّهَا الَّذِينَ آمَنُوا تُوبُوا إِلَى اللَّهِ تَوْبَةً نَّصُوحًا",
            verseTranslation: "O you who have believed, repent to Allah with sincere repentance. Perhaps your Lord will remove from you your misdeeds and admit you into gardens beneath which rivers flow.",
            verseReference: "Quran 66:8",
            content: """
Tawbah isn't just saying "I'm sorry." It's a complete turning—a redirection of your heart and actions toward Allah.

The word "tawbah" comes from the Arabic root meaning "to return." When you sin, you've wandered from the path. Tawbah is the journey back.

The Components of Sincere Tawbah:

1. Acknowledgment: Recognizing the sin without excuses or minimization. Not "I slipped" but "I chose wrongly."

2. Remorse: Genuine regret—not just fear of consequences, but sorrow for having disobeyed your Creator who has given you everything.

3. Stopping: Ceasing the sinful behavior. Tawbah while continuing the sin isn't tawbah.

4. Resolve: Firm intention not to return to it. This doesn't mean you'll never struggle, but your commitment is sincere.

5. Repair: If your sin harmed others, making amends where possible.

Here's what many people miss: tawbah isn't a one-time event. The Prophet ﷺ sought forgiveness over 70 times daily—and he was sinless. For us, tawbah is a constant practice.

When you fall—and you might—don't let shame delay your return. The door to Allah is always open. He says in a Hadith Qudsi: "O son of Adam, as long as you call upon Me and put your hope in Me, I will forgive you for what you have done, and I do not mind."

Every moment is a new opportunity to return.
""",
            reflection: "When you think about tawbah, what feelings come up? What might be preventing you from turning fully to Allah?",
            readTimeMinutes: 3
        ),

        // Day 9
        LessonContent(
            id: 9,
            title: "Lowering the Gaze",
            verse: "قُل لِّلْمُؤْمِنِينَ يَغُضُّوا مِنْ أَبْصَارِهِمْ وَيَحْفَظُوا فُرُوجَهُمْ",
            verseTranslation: "Tell the believing men to lower their gaze and guard their private parts. That is purer for them. Indeed, Allah is Acquainted with what they do.",
            verseReference: "Quran 24:30",
            content: """
The battle for purity begins with the eyes. This verse establishes a direct connection: lowering the gaze leads to guarding the private parts. The reverse is also true—unguarded eyes lead to unguarded actions.

In our era of screens, "lowering the gaze" extends beyond physical sight. It includes:
• What you scroll past (or pause on)
• What you search for
• What you allow algorithms to show you
• The content you consume even when "not looking for anything"

Practical Steps:

The First Glance vs. The Second: The Prophet ﷺ told Ali (may Allah be pleased with him): "Do not follow one glance with another. The first is for you, but the second is against you." You can't always control what enters your vision, but you control whether you linger.

Digital Discipline: Treat your phone like your gaze. Quick, purposeful use. Not mindless scrolling that leads eyes where they shouldn't go.

Immediate Redirect: When you see something triggering, have a practiced response. Look away physically. Say "Astaghfirullah." Redirect to something else.

Know Your Weaknesses: Some content isn't explicitly haram but activates your addiction pathways. Fitness content, certain social media pages, even movie scenes. Be ruthlessly honest about what affects you specifically.

The sweetness of lowering the gaze for Allah is something you'll taste only by practicing it. It's a form of worship—a private jihad between you and your Lord that no one else sees.
""",
            reflection: "Where do you most struggle with guarding your gaze? What's one specific boundary you can set today?",
            readTimeMinutes: 3
        ),

        // Day 10
        LessonContent(
            id: 10,
            title: "Salah as Protection",
            verse: "إِنَّ الصَّلَاةَ تَنْهَىٰ عَنِ الْفَحْشَاءِ وَالْمُنكَرِ",
            verseTranslation: "Recite what has been revealed to you of the Book and establish prayer. Indeed, prayer prohibits immorality and wrongdoing, and the remembrance of Allah is greater.",
            verseReference: "Quran 29:45",
            content: """
Prayer is described as a protection against immorality—not just a ritual obligation. But how does this actually work?

The Five Daily Anchors: Salah structures your day around remembrance of Allah. Every few hours, you pause everything to stand before Him. This rhythm interrupts the autopilot mode where sins often happen.

The Physical Reset: Wudu isn't just purification—it's a transition. When you feel urges, making wudu can physically break the mental loop. Cold water on your face, the deliberate motions, the intention—these redirect your nervous system.

The Spiritual Shield: When you pray with presence (khushu'), you're reminded of who you are and Whose you are. It's harder to sin when you've just spoken directly to Allah.

The Honest Mirror: Your relationship with salah often reflects your spiritual state. When you're struggling with addiction, prayer becomes difficult—you feel unworthy, distracted, going through motions. But this is precisely when you need it most.

Practical Applications:

• Pray on time, especially Fajr. Winning the morning sets the day's tone.
• When urges hit, pray two extra rak'ahs. This isn't a magic formula, but it redirects your body and mind toward Allah.
• Don't let shame keep you from prayer. Pray even if you fell an hour ago. Especially then.

The worst thing Shaytan wants is for your sin to stop you from prayer. Don't give him that victory.
""",
            reflection: "How has your prayer life been affected by your struggle? What would it look like to use salah actively as protection?",
            readTimeMinutes: 3
        ),

        // Day 11
        LessonContent(
            id: 11,
            title: "The Power of Dhikr",
            verse: "أَلَا بِذِكْرِ اللَّهِ تَطْمَئِنُّ الْقُلُوبُ",
            verseTranslation: "Verily, in the remembrance of Allah do hearts find rest.",
            verseReference: "Quran 13:28",
            content: """
The restlessness that drives addiction—the constant seeking, the inability to feel satisfied—finds its answer in this verse. Hearts find rest in Allah's remembrance.

Dhikr isn't just repetitive chanting. It's conscious awareness of Allah woven into your day. And it's one of the most accessible yet powerful tools in recovery.

Why Dhikr Works:

Neurological: Repetitive, focused phrases calm the nervous system. They activate the parasympathetic response—the opposite of the fight-or-flight mode that often precedes relapse.

Psychological: Dhikr redirects your mental attention. When urges arise, your mind needs somewhere else to go. Dhikr provides that pathway.

Spiritual: Regular remembrance builds a connection with Allah that makes sin feel more distant. The heart that's full has less room for emptiness to exploit.

Practical Dhikr for Recovery:

Morning & Evening Adhkar: The Prophet ﷺ taught specific supplications for these times. They create spiritual bookends to your day.

In the Moment: When urges hit, have phrases ready:
• "Astaghfirullah" (I seek Allah's forgiveness)
• "La hawla wa la quwwata illa billah" (There is no power except with Allah)
• "Ya Muqallib al-quloob, thabbit qalbi 'ala deenik" (O Turner of hearts, make my heart firm upon Your religion)

Throughout the Day: SubhanAllah, Alhamdulillah, Allahu Akbar—said with presence, not just habit. The Prophet ﷺ said these are beloved to Allah and light on the tongue but heavy on the scales.

Start small. Ten minutes of morning adhkar. A phrase when you feel weak. Build from there. The goal isn't quantity—it's making remembrance your reflex.
""",
            reflection: "When do you feel most disconnected from Allah? How could dhikr fill those moments?",
            readTimeMinutes: 3
        ),

        // Day 12
        LessonContent(
            id: 12,
            title: "Fasting as Training",
            verse: "يَا أَيُّهَا الَّذِينَ آمَنُوا كُتِبَ عَلَيْكُمُ الصِّيَامُ كَمَا كُتِبَ عَلَى الَّذِينَ مِن قَبْلِكُمْ لَعَلَّكُمْ تَتَّقُونَ",
            verseTranslation: "O you who have believed, fasting has been prescribed for you as it was prescribed for those before you, that you may become mindful of Allah.",
            verseReference: "Quran 2:183",
            content: """
Fasting is Allah's training program for self-control. When the Prophet ﷺ was asked about controlling desires, he recommended fasting. There's wisdom here worth exploring.

What Fasting Teaches:

Delayed Gratification: The core dysfunction in addiction is wanting immediate pleasure despite long-term harm. Fasting practices the opposite—accepting temporary discomfort for greater good.

Body-Mind Connection: When you fast, you become aware of how physical states affect your thoughts. Hunger is a craving. You learn to observe it without obeying it. This skill transfers directly to other urges.

Spiritual Sensitivity: An empty stomach creates an open heart. Fasting weakens the nafs (lower self) and strengthens spiritual awareness. Many people report feeling closest to Allah while fasting.

Practical Approaches:

Regular Voluntary Fasts: Mondays and Thursdays (Sunnah), or three days each month. These create consistent training without overwhelming yourself.

Strategic Fasting: If you know certain days are harder—like weekends alone—consider fasting those days. It's harder to fall when you're in a state of worship.

The Prophet's Advice: He specifically said fasting helps those who struggle with desires but cannot marry yet. This isn't ancient wisdom that's lost relevance—it's timeless guidance for a timeless struggle.

One Important Note: Fasting isn't punishment for past sins. It's building strength for future challenges. Approach it as training, not self-flagellation.

Start with what's manageable. One day a week. Build from there. The discipline you develop in controlling hunger creates discipline that extends to all desires.
""",
            reflection: "Have you noticed any connection between fasting and your ability to resist urges? How might you incorporate voluntary fasting into your recovery?",
            readTimeMinutes: 3
        ),

        // Day 13
        LessonContent(
            id: 13,
            title: "The Night Prayers",
            verse: "وَمِنَ اللَّيْلِ فَتَهَجَّدْ بِهِ نَافِلَةً لَّكَ عَسَىٰ أَن يَبْعَثَكَ رَبُّكَ مَقَامًا مَّحْمُودًا",
            verseTranslation: "And from part of the night, pray with it as additional worship for you; it is expected that your Lord will raise you to a praised station.",
            verseReference: "Quran 17:79",
            content: """
The last third of the night is described in hadith as the time when Allah descends to the lowest heaven and asks: "Is there anyone seeking forgiveness that I may forgive? Is there anyone asking that I may give?"

This time—when the world sleeps and distractions fade—holds special power for those seeking change.

Why Night Prayer Matters for Recovery:

The Vulnerable Hours: For many, late night is when urges peak. Instead of fighting emptiness with more scrolling, tahajjud fills the darkness with light.

Private Worship: No one sees your night prayers except Allah. This privacy builds a relationship that isn't performative—it's real.

The Broken-Hearted Advantage: You might feel too sinful to stand before Allah. But the night prayer is where the broken come. The Prophet ﷺ said Allah stretches out His hand at night to forgive those who sinned during the day.

Getting Started:

Start Small: Even two rak'ahs before Fajr counts. Don't aim for hours immediately.

Set an Alarm: 30 minutes before Fajr. Make wudu. Pray what you can.

Du'a After: The time after tahajjud and before Fajr is special for supplication. Pour out your heart. Ask for strength. Be completely honest about your struggle.

Consistency Over Intensity: Two rak'ahs every night beats an hour once a month. Build the habit first.

The night prayer isn't just about accumulating good deeds. It's about building a private relationship with Allah that sustains you through every other hour. When you've stood before Him in the silence of the night, the daylight struggles feel more manageable.
""",
            reflection: "What would it look like to dedicate even 10 minutes before Fajr to standing before Allah? What's stopping you from starting tonight?",
            readTimeMinutes: 3
        ),

        // Day 14
        LessonContent(
            id: 14,
            title: "Week 2 Reflection",
            verse: "فَاذْكُرُونِي أَذْكُرْكُمْ وَاشْكُرُوا لِي وَلَا تَكْفُرُونِ",
            verseTranslation: "So remember Me; I will remember you. And be grateful to Me and do not deny Me.",
            verseReference: "Quran 2:152",
            content: """
Two weeks. You're building something real.

This week focused on spiritual tools—practical acts of worship that protect and strengthen:

Day 8: Tawbah is always available. The door to Allah never closes. Return quickly when you fall.

Day 9: The gaze is the gateway. Lowering it—physically and digitally—prevents the chain reaction that leads to sin.

Day 10: Salah structures your day around Allah's remembrance and physically interrupts the patterns of sin.

Day 11: Dhikr fills the restless heart. Regular remembrance creates calm that addiction falsely promises.

Day 12: Fasting trains delayed gratification—the exact skill addiction destroys.

Day 13: Night prayer builds a private relationship with Allah that sustains you through public struggles.

The Common Thread: These aren't random rituals. Each one addresses something addiction exploits—the seeking heart, the wandering eyes, the untrained desires, the lonely nights. Islam provides the complete toolkit. Your job is to use it.

At this point in recovery, you might feel:
• Stronger and more hopeful
• Still struggling but more aware
• Frustrated that it's not easier yet
• A mix of all the above

All of these are valid. Two weeks of brain rewiring and spiritual rebuilding is significant progress, even when it doesn't feel dramatic.

The coming week will shift focus to emotional and psychological dimensions—understanding the feelings beneath the behavior and developing healthier responses to them.

Keep going. Each day you stay on this path, you're becoming someone new.
""",
            reflection: "Which spiritual tool from this week resonated most with you? How will you incorporate it more deeply into your daily life?",
            readTimeMinutes: 3
        ),

        // Day 15
        LessonContent(
            id: 15,
            title: "Shame vs. Guilt",
            verse: "قَالَ رَبِّ إِنِّي ظَلَمْتُ نَفْسِي فَاغْفِرْ لِي فَغَفَرَ لَهُ",
            verseTranslation: "He said, 'My Lord, indeed I have wronged myself, so forgive me,' and He forgave him.",
            verseReference: "Quran 28:16",
            content: """
There's a crucial difference between guilt and shame that affects your recovery.

Guilt says: "I did something bad."
Shame says: "I am bad."

Guilt is about behavior. Shame is about identity. One motivates change; the other paralyzes it.

When Musa (peace be upon him) accidentally killed a man, he didn't say "I am worthless." He said "I have wronged myself"—acknowledging the act while seeking forgiveness. Allah forgave him immediately.

The Shame Trap:

Shame tells you: "You've tried to quit so many times. You're just that kind of person. You'll never change."

This lie keeps people stuck. If you believe you're fundamentally broken, why bother trying? Shame becomes a self-fulfilling prophecy—you sin because you believe sinning is who you are.

The Guilt Pathway:

Healthy guilt says: "That action was wrong. It doesn't align with who I want to be or who Allah created me to be. I need to change the behavior."

This preserves hope. You're not fighting your identity—you're aligning your actions with your true self, the self Allah created in fitrah (pure nature).

Practical Shifts:

When you fall, notice your self-talk:
• Shame: "I'm disgusting. I'm a hypocrite. I'm hopeless."
• Guilt: "That was wrong. I regret it. I'm going to try again."

Replace "I am" statements with "I did" statements. You did something sinful. You are not the sin itself.

Remember: Allah forgives actions. He doesn't ask you to hate yourself. He asks you to return to Him.
""",
            reflection: "Do you tend toward shame or guilt after falling? How has shame specifically held you back in your recovery?",
            readTimeMinutes: 3
        ),

        // Day 16
        LessonContent(
            id: 16,
            title: "Emotional Awareness",
            verse: "إِنَّ اللَّهَ عَلِيمٌ بِذَاتِ الصُّدُورِ",
            verseTranslation: "Indeed, Allah is Knowing of what is within the breasts.",
            verseReference: "Quran 3:119",
            content: """
Before every relapse, there's an emotion. Learning to identify and name your feelings is a powerful recovery skill.

Many people use pornography not primarily for pleasure, but for escape. They're running from feelings they don't know how to handle: loneliness, stress, boredom, anxiety, sadness, even certain kinds of joy.

The HALT Framework:

Check yourself when urges arise. Are you:
• Hungry – Physical needs affect emotional regulation
• Angry – Including frustrated, irritated, resentful
• Lonely – Disconnected, isolated, misunderstood
• Tired – Sleep deprivation weakens all defenses

These four states are common relapse triggers. Addressing the actual need—eating, processing anger, connecting with someone, resting—often dissolves the urge.

Going Deeper:

Beyond HALT, get curious about your emotional landscape:
• What were you feeling in the hour before your last relapse?
• What feelings do you most avoid experiencing?
• When you feel the urge, what's underneath it?

Allah knows what's in your chest—even the feelings you hide from yourself. Part of your journey is becoming aware of what He already sees.

Building Emotional Vocabulary:

Start naming your feelings specifically. Not just "bad" but: anxious, overwhelmed, rejected, inadequate, empty, bored, restless, sad, angry, ashamed.

The more precisely you can identify what you're feeling, the more options you have for responding. "I'm lonely and need connection" has different solutions than "I'm stressed and need relief."

Awareness doesn't automatically fix anything. But it creates space between stimulus and response—space where choice lives.
""",
            reflection: "What emotion most commonly precedes your urges? What does that feeling actually need (not what addiction offers as a false solution)?",
            readTimeMinutes: 3
        ),

        // Day 17
        LessonContent(
            id: 17,
            title: "The Loneliness Factor",
            verse: "وَخَلَقْنَاكُمْ أَزْوَاجًا",
            verseTranslation: "And We created you in pairs.",
            verseReference: "Quran 78:8",
            content: """
Humans are created for connection. Loneliness isn't a character flaw—it's a signal that a fundamental need isn't being met.

The Connection Between Loneliness and Addiction:

Addiction researcher Johann Hari summarized years of study: "The opposite of addiction is not sobriety. The opposite of addiction is connection."

When real human connection is absent or inadequate, people seek substitutes. Pornography offers a counterfeit intimacy—it mimics connection without requiring vulnerability. It's available without rejection risk.

But the relief is temporary and ultimately deepens the isolation. The shame that follows makes real connection harder. It's a cycle that feeds itself.

Types of Loneliness:

Social Loneliness: Lack of friendships and community. You might be around people but not truly known by them.

Emotional Loneliness: Absence of a close confidant. No one you can be completely honest with.

Spiritual Loneliness: Disconnection from Allah. Prayers feel empty. You feel distant from the Divine.

Breaking the Cycle:

Address Social Loneliness: Join communities—masjid programs, interest-based groups, volunteer work. Prioritize in-person over online.

Address Emotional Loneliness: Risk vulnerability with one trusted person. Share something real about your struggle.

Address Spiritual Loneliness: Allah is Al-Wadud (The Loving) and Al-Qarib (The Near). Talk to Him honestly. He responds to the broken-hearted.

The addiction thrives in isolation. Every genuine connection you build weakens its grip.
""",
            reflection: "Which type of loneliness affects you most? What's one step you could take this week toward greater connection?",
            readTimeMinutes: 3
        ),

        // Day 18
        LessonContent(
            id: 18,
            title: "Healthy Coping",
            verse: "فَإِنَّ مَعَ الْعُسْرِ يُسْرًا",
            verseTranslation: "For indeed, with hardship comes ease.",
            verseReference: "Quran 94:5",
            content: """
Addiction is often a coping mechanism—a way to manage stress, pain, or discomfort. Recovery requires developing healthier alternatives.

Why We Need Coping Skills:

Life contains difficulty. The verse above promises that ease comes with hardship—not instead of it. You need ways to navigate the hard parts without destroying yourself in the process.

Pornography was your go-to solution for too long. It "worked" in the short term—it provided escape, numbed pain, offered stimulation. But the cost was devastating: shame, wasted time, spiritual distance, relationship damage.

You're not just removing a coping mechanism. You're replacing it with better ones.

Building Your Toolkit:

Physical Release:
• Exercise—even a 10-minute walk changes your state
• Cold showers (especially when urges hit)
• Deep breathing exercises
• Physical labor or cleaning

Emotional Processing:
• Journaling—writing what you feel
• Talking to someone
• Crying when needed (the Prophet ﷺ wept)
• Making du'a and telling Allah everything

Mental Redirect:
• Engaging work or study
• Learning something new
• Helping someone else
• Changing your environment (leave the room)

Spiritual Anchoring:
• Wudu and prayer
• Dhikr and recitation
• Listening to Islamic lectures
• Sitting in the masjid

The key is having options ready before you need them. When urges hit, your brain seeks the easiest path. Make healthy paths easy and accessible.
""",
            reflection: "What healthy coping mechanisms already work for you? What new ones could you add to your toolkit?",
            readTimeMinutes: 3
        ),

        // Day 19
        LessonContent(
            id: 19,
            title: "Self-Compassion",
            verse: "وَرَحْمَتِي وَسِعَتْ كُلَّ شَيْءٍ",
            verseTranslation: "And My mercy encompasses all things.",
            verseReference: "Quran 7:156",
            content: """
If Allah's mercy encompasses everything, should yours exclude yourself?

Self-compassion isn't self-indulgence. It's not making excuses or lowering standards. It's treating yourself with the kindness you'd extend to a friend who was struggling.

The Self-Criticism Trap:

Many religious people believe harsh self-criticism is virtuous. They think beating themselves up after sin shows true repentance. But research shows the opposite: excessive self-criticism actually increases relapse rates. When you feel worthless, you have less reason to protect yourself from harm.

What Self-Compassion Looks Like:

Mindfulness: Acknowledging your struggle without exaggerating or minimizing. "This is hard. I'm having a difficult moment."

Common Humanity: Recognizing you're not uniquely broken. "Other people struggle with this too. I'm not alone in this."

Self-Kindness: Speaking to yourself gently. Not "I'm pathetic" but "I'm learning. I'm trying. This is part of the process."

The Islamic Framework:

Allah is Ar-Rahman and Ar-Raheem—His mercy is emphasized more than any other attribute. He tells us not to despair of His mercy. He forgives repeatedly. He loves those who repent.

If Allah—who is perfectly just and knows all your sins in detail—responds with mercy, who are you to respond to yourself with only harshness?

The Prophet ﷺ said Allah is more merciful to His servants than a mother is to her child. Can you imagine a mother wanting her struggling child to hate themselves? Neither does Allah want that for you.

Self-compassion isn't weakness. It's alignment with how Allah treats you.
""",
            reflection: "How do you typically speak to yourself after a failure? What would change if you spoke to yourself with compassion instead?",
            readTimeMinutes: 3
        ),

        // Day 20
        LessonContent(
            id: 20,
            title: "Sabr - Patient Perseverance",
            verse: "يَا أَيُّهَا الَّذِينَ آمَنُوا اسْتَعِينُوا بِالصَّبْرِ وَالصَّلَاةِ",
            verseTranslation: "O you who have believed, seek help through patience and prayer. Indeed, Allah is with the patient.",
            verseReference: "Quran 2:153",
            content: """
Sabr is mentioned over 90 times in the Quran. It's central to everything Muslims are called to do. In recovery, it's indispensable.

Understanding Sabr:

Sabr is often translated as "patience," but it's richer than passive waiting. It includes:
• Perseverance through difficulty
• Restraint from what's forbidden
• Consistency in what's required
• Endurance without complaint

All four dimensions apply to your recovery.

The Three Types of Sabr:

Sabr in Obedience: Continuing prayers, dhikr, and good habits even when motivation fades. Showing up when you don't feel like it.

Sabr from Disobedience: Holding back from sin when desire is strong. This is the moment of truth—when urges peak and you choose restraint.

Sabr Through Trials: Accepting the difficulty of recovery without bitterness. Understanding that the struggle itself has value.

Practical Sabr:

"Urge Surfing": When an urge hits, don't fight it directly or feed it. Observe it. Know it will peak and pass. The average urge lasts 15-30 minutes if not fed. You can endure that.

The 10-Minute Rule: When tempted, commit to wait 10 minutes before acting. Often the urge weakens. Add another 10 minutes. This builds the sabr muscle.

Daily Sabr: Remember that every day clean is an act of sabr. Every prayer prayed, every gaze lowered, every boundary maintained. These accumulate.

Allah promises He is "with the patient." That companionship is the ultimate reward—greater than any pleasure sin could offer.
""",
            reflection: "In which dimension of sabr do you need the most growth? What's one way you can practice it today?",
            readTimeMinutes: 3
        ),

        // Day 21
        LessonContent(
            id: 21,
            title: "Week 3 Reflection",
            verse: "وَنَفْسٍ وَمَا سَوَّاهَا فَأَلْهَمَهَا فُجُورَهَا وَتَقْوَاهَا قَدْ أَفْلَحَ مَن زَكَّاهَا",
            verseTranslation: "And by the soul and He who proportioned it, and inspired it with its wickedness and its righteousness. Successful is the one who purifies it.",
            verseReference: "Quran 91:7-9",
            content: """
Three weeks. The soul Allah created contains both potential for wickedness and righteousness. Success comes from purification—and that's exactly what you're doing.

This week explored the emotional and psychological dimensions of recovery:

Day 15: Shame paralyzes; guilt motivates. You did something wrong—you are not the wrong itself.

Day 16: Emotions drive behavior. Naming what you feel creates space for healthier responses.

Day 17: Loneliness fuels addiction. Real connection—social, emotional, spiritual—is the antidote.

Day 18: You need coping mechanisms. Build a toolkit of healthy alternatives before you need them.

Day 19: Self-compassion isn't weakness. Allah's mercy encompasses everything; yours should include yourself.

Day 20: Sabr is active endurance. You can outlast urges. Every day clean is an act of patient perseverance.

The Deeper Work:

The first two weeks addressed external factors (environment, triggers) and spiritual practices. This week went internal—to the feelings and patterns that drive behavior beneath the surface.

This is harder work. Changing your environment is concrete. Understanding your emotions requires honesty that can be uncomfortable. But this inner work is what creates lasting change.

You're not just avoiding a behavior. You're healing the wounds that made the behavior feel necessary. You're becoming someone for whom this addiction no longer makes sense.

One more week of lessons remains. Then the real journey continues—applying everything you've learned, day after day, building the life you want.
""",
            reflection: "What emotional insight from this week surprised you most? How will understanding your inner world help your recovery?",
            readTimeMinutes: 3
        ),

        // Day 22
        LessonContent(
            id: 22,
            title: "Identity Transformation",
            verse: "وَمَن يُسْلِمْ وَجْهَهُ إِلَى اللَّهِ وَهُوَ مُحْسِنٌ فَقَدِ اسْتَمْسَكَ بِالْعُرْوَةِ الْوُثْقَىٰ",
            verseTranslation: "And whoever submits his face to Allah while being a doer of good has grasped the most trustworthy handhold.",
            verseReference: "Quran 31:22",
            content: """
There's a point in recovery where you stop being "someone who's trying to quit" and become "someone who doesn't do this." This shift in identity is transformative.

The Identity Model:

Most people try to change behavior through willpower: "I want to watch porn, but I'll resist." This requires constant effort because you're fighting against who you believe you are.

Identity-based change works differently: "I'm not someone who does that." The behavior stops aligning with your self-concept. You're not resisting—you're being yourself.

Making the Shift:

From: "I'm an addict trying to recover."
To: "I'm a servant of Allah who had a struggle, and I'm moving past it."

From: "I can't do this because it's haram."
To: "I don't do this because it's not who I am."

The difference is subtle but powerful. One requires constant vigilance against your nature. The other expresses your true nature.

Your True Identity:

Allah created you in fitrah—a pure, natural state inclined toward good. The addiction isn't your identity; it's a deviation from it. Recovery isn't becoming someone new—it's returning to who you truly are.

Every choice aligned with your fitrah reinforces your true identity. "This is who I am." Every prayer, every lowered gaze, every moment of restraint is evidence that you are who you want to be.

You're not fighting yourself. You're becoming yourself.
""",
            reflection: "How do you currently see your identity in relation to this struggle? What would it look like to see yourself as someone who simply doesn't engage in this behavior?",
            readTimeMinutes: 3
        ),

        // Day 23
        LessonContent(
            id: 23,
            title: "Building Healthy Habits",
            verse: "وَأَن لَّيْسَ لِلْإِنسَانِ إِلَّا مَا سَعَىٰ",
            verseTranslation: "And that there is not for man except that for which he strives.",
            verseReference: "Quran 53:39",
            content: """
Recovery isn't just about removing a bad habit—it's about building a life where that habit no longer fits. Your daily routines either support your goals or undermine them.

The Habit Loop:

Every habit follows a pattern: Cue → Routine → Reward.

Your addiction had this structure. Certain cues (boredom, late night, phone in hand) triggered routines (searching, watching) for rewards (dopamine, escape).

You can't just delete a habit—you need to replace it. Keep some cues, change the routine, find healthier rewards.

Keystone Habits:

Some habits have outsized influence. For recovery, consider:

Morning Routine: How you start the day affects everything. Include Fajr, dhikr, and intention-setting. A strong morning creates momentum.

Sleep Routine: Most relapses happen late at night. Set a consistent bedtime. No screens in bed. Make sleep a priority, not an afterthought.

Phone Habits: Define when and how you use your phone. Specific times for specific purposes. Never mindless scrolling—it's too dangerous.

Physical Activity: Exercise releases endorphins naturally, reduces stress, and builds discipline. Even daily walks count.

Building New Habits:

Start small—so small it feels trivial. Two minutes of morning dhikr. Five push-ups. Reading one page of Quran. Small enough that you can't fail.

Stack new habits onto existing ones. "After I pray Fajr, I will read one page of Quran." The existing habit becomes the cue for the new one.

Track your consistency. Visible progress motivates continued effort.
""",
            reflection: "What's one keystone habit you could establish that would positively affect multiple areas of your life? How will you start it this week?",
            readTimeMinutes: 3
        ),

        // Day 24
        LessonContent(
            id: 24,
            title: "Physical Wellness",
            verse: "وَكُلُوا وَاشْرَبُوا وَلَا تُسْرِفُوا",
            verseTranslation: "And eat and drink, but be not excessive. Indeed, He does not like those who commit excess.",
            verseReference: "Quran 7:31",
            content: """
Your body and soul are connected. Physical wellness isn't separate from spiritual recovery—it's part of it.

The Body-Mind Connection:

When your body is depleted, your mind is vulnerable. Sleep deprivation, poor nutrition, and lack of exercise all weaken your ability to resist temptation and make good decisions.

The Prophet ﷺ said: "Your body has a right over you." Honoring that right supports every other aspect of recovery.

Sleep:

Sleep deprivation is one of the strongest predictors of relapse. When you're exhausted:
• Willpower decreases dramatically
• Emotional regulation suffers
• Cravings intensify
• Late-night vulnerability increases

Aim for 7-8 hours. Consistent sleep and wake times. No screens before bed.

Nutrition:

What you eat affects your brain chemistry. Balanced meals maintain steady energy and mood. Excessive sugar and processed foods create spikes and crashes that can trigger cravings.

Eating with consciousness—not excessively—is Islamic guidance that serves your recovery.

Exercise:

Regular physical activity:
• Releases natural endorphins (healthy dopamine)
• Reduces stress and anxiety
• Improves sleep quality
• Builds discipline and self-efficacy
• Provides healthy outlet for energy

You don't need a gym membership. Walking, bodyweight exercises, sports with friends—anything that moves your body consistently.

The body Allah gave you is a trust. Caring for it isn't vanity—it's responsibility. And a well-maintained body supports a well-maintained soul.
""",
            reflection: "Which aspect of physical wellness needs the most attention in your life? What's one specific improvement you can make starting today?",
            readTimeMinutes: 3
        ),

        // Day 25
        LessonContent(
            id: 25,
            title: "Purpose and Contribution",
            verse: "وَمَا خَلَقْتُ الْجِنَّ وَالْإِنسَ إِلَّا لِيَعْبُدُونِ",
            verseTranslation: "And I did not create the jinn and mankind except to worship Me.",
            verseReference: "Quran 51:56",
            content: """
Addiction often thrives in a vacuum of purpose. When life feels meaningless, escape becomes appealing. Recovery is strengthened when you're building something meaningful.

The Purpose Connection:

People with strong sense of purpose have significantly better recovery outcomes. Purpose provides:
• Reason to protect yourself from harm
• Direction for your energy and attention
• Meaning that makes sacrifice worthwhile
• Identity beyond the struggle

Your ultimate purpose—worshipping Allah—encompasses everything, but it expresses itself through specific actions in your life.

Finding Your Contribution:

Ask yourself:
• What skills or knowledge do you have?
• What problems do you notice that you could help solve?
• Who in your community needs what you can offer?
• What work feels meaningful, not just obligatory?

Forms of Contribution:

Service: Volunteer work, helping at the masjid, supporting those in need. The Prophet ﷺ said the best people are those most beneficial to others.

Knowledge: Teaching what you know—Quran, academics, professional skills. Knowledge passed on multiplies in reward.

Creation: Building something useful—a business, content, projects that serve others.

Support: Being there for people who struggle. Your recovery journey gives you understanding that can help others.

The Energy Redirect:

Addiction consumes enormous energy—time, mental space, emotional bandwidth. As you recover, that energy becomes available. Direct it toward something constructive. Don't leave a vacuum for old habits to fill.

What will you build with the life you're reclaiming?
""",
            reflection: "What gives your life meaning beyond yourself? How can you increase your contribution to others as part of your recovery?",
            readTimeMinutes: 3
        ),

        // Day 26
        LessonContent(
            id: 26,
            title: "Healing Your View of Intimacy",
            verse: "وَمِنْ آيَاتِهِ أَنْ خَلَقَ لَكُم مِّنْ أَنفُسِكُمْ أَزْوَاجًا لِّتَسْكُنُوا إِلَيْهَا وَجَعَلَ بَيْنَكُم مَّوَدَّةً وَرَحْمَةً",
            verseTranslation: "And of His signs is that He created for you from yourselves mates that you may find tranquility in them; and He placed between you affection and mercy.",
            verseReference: "Quran 30:21",
            content: """
Pornography doesn't just harm your present—it distorts your understanding of intimacy, affecting your future relationships.

What Pornography Teaches (Wrongly):

• Intimacy is about taking, not giving
• People are objects for consumption
• Novelty is more exciting than commitment
• Emotional connection is unnecessary
• Unrealistic expectations are normal

These lies seep into your subconscious and affect how you view potential spouses, marriage, and intimacy itself.

What Islam Teaches:

The verse above describes marriage as a source of tranquility (sakinah), affection (mawaddah), and mercy (rahmah). This is intimacy as Allah designed it—not transactional, but relational.

Real intimacy involves:
• Vulnerability and trust
• Giving as much as receiving
• Growing together over time
• Emotional and spiritual connection
• Commitment and loyalty

The Healing Process:

Rewiring Your Brain: As you abstain, your brain's warped expectations begin to normalize. You start finding real people attractive in real ways.

Resetting Expectations: Study Islamic teachings on marriage. Learn what healthy relationships actually look like. Replace distorted images with truthful understanding.

Addressing Underlying Issues: If fear of rejection or intimacy contributed to your addiction, explore those wounds. Sometimes pornography is a way to have "safe" intimacy without vulnerability risk.

Whether you're single or married, recovery includes healing your capacity for real, meaningful connection. You're not just quitting something harmful—you're becoming capable of something beautiful.
""",
            reflection: "How has this addiction affected your view of intimacy and relationships? What would a healthy understanding look like for you?",
            readTimeMinutes: 3
        ),

        // Day 27
        LessonContent(
            id: 27,
            title: "When You Fall",
            verse: "وَالَّذِينَ إِذَا فَعَلُوا فَاحِشَةً أَوْ ظَلَمُوا أَنفُسَهُمْ ذَكَرُوا اللَّهَ فَاسْتَغْفَرُوا لِذُنُوبِهِمْ",
            verseTranslation: "And those who, when they commit an immorality or wrong themselves, remember Allah and seek forgiveness for their sins—and who can forgive sins except Allah?",
            verseReference: "Quran 3:135",
            content: """
Relapses may happen. What matters is how you respond.

The Danger of All-or-Nothing Thinking:

"I already failed, so I might as well keep going."
"I'm back to zero—what's the point?"
"I'll never change. I've proven it again."

This thinking transforms a slip into a full relapse. It's called the "abstinence violation effect"—where breaking a commitment leads to abandoning it entirely.

Resist this pattern. A fall is not a failure. It's information.

The Immediate Response:

1. Stop immediately. One sin doesn't justify two. Close everything. Leave the environment.

2. Make wudu. The physical act interrupts the mental spiral. The Prophet ﷺ said sins are washed away with wudu.

3. Pray two rak'ahs. Return to Allah right away. Don't wait until you "feel ready."

4. Make tawbah sincerely. The verse above describes exactly this—remembering Allah immediately and seeking forgiveness.

The Analytical Response (Later):

Once you've stabilized:
• What led to this? Trace the chain of events.
• What was the emotional trigger?
• Where did your safeguards fail?
• What can you adjust for next time?

This isn't self-criticism—it's data collection. Every fall teaches something if you're willing to learn.

The Forward Response:

Don't "reset" your identity. You haven't become your old self. You had a setback in an ongoing transformation. Get back on the path the same day.

The believers Allah describes "seek forgiveness for their sins." Notice the plural—sins happen. What defines you is the seeking of forgiveness, not the perfection of never falling.
""",
            reflection: "How have you typically responded to relapses in the past? What would a healthier response look like based on what you've learned?",
            readTimeMinutes: 3
        ),

        // Day 28
        LessonContent(
            id: 28,
            title: "Week 4 Reflection",
            verse: "وَعَسَىٰ أَن تَكْرَهُوا شَيْئًا وَهُوَ خَيْرٌ لَّكُمْ",
            verseTranslation: "Perhaps you hate a thing and it is good for you.",
            verseReference: "Quran 2:216",
            content: """
Four weeks. You've done profound work. The struggle you hated has become a pathway to growth you couldn't have found otherwise.

This week focused on building your new life:

Day 22: Identity transformation—from "addict trying to quit" to "person who doesn't do this." Be who you truly are.

Day 23: Healthy habits—building routines that support your recovery, not undermine it. Structure protects.

Day 24: Physical wellness—sleep, nutrition, exercise. Your body and soul are connected.

Day 25: Purpose and contribution—directing recovered energy toward something meaningful. Build what matters.

Day 26: Healing intimacy—rewiring distorted views and becoming capable of real connection.

Day 27: Responding to setbacks—falls aren't failures. Immediate tawbah, analysis, and continuation.

The Bigger Picture:

You've now covered:
• Week 1: Understanding addiction and laying foundations
• Week 2: Spiritual tools and practices
• Week 3: Emotional and psychological dimensions
• Week 4: Building a new life

This isn't a 30-day program that "fixes" you. It's a foundation for ongoing growth. The patterns you've established will serve you long beyond these lessons.

The verse today reminds us that what we hate can contain hidden good. Your struggle with this addiction—as painful as it's been—has led you to deeper understanding of yourself, closer connection to Allah, and tools that will serve you in every challenge you face.

Two more lessons remain. Then the real work continues.
""",
            reflection: "What unexpected good has come from this struggle? How has the difficulty shaped you in positive ways?",
            readTimeMinutes: 3
        ),

        // Day 29
        LessonContent(
            id: 29,
            title: "Looking Forward",
            verse: "وَلَا تَيْأَسُوا مِن رَّوْحِ اللَّهِ إِنَّهُ لَا يَيْأَسُ مِن رَّوْحِ اللَّهِ إِلَّا الْقَوْمُ الْكَافِرُونَ",
            verseTranslation: "And do not despair of the mercy of Allah. Indeed, none despairs of the mercy of Allah except the disbelieving people.",
            verseReference: "Quran 12:87",
            content: """
Recovery isn't a destination—it's a direction. As you look forward, here's what to expect and how to prepare.

The Road Ahead:

Days 30-90: Brain chemistry continues normalizing. Urges typically decrease in frequency and intensity. But unexpected triggers can still catch you off guard. Stay vigilant.

Months 3-6: New habits become more automatic. The "flatline" period should lift. You may start feeling more alive, more present, more yourself.

Beyond: Recovery becomes integrated into life. The struggle doesn't define you. You've developed tools that serve you in all areas.

Maintenance Strategies:

Keep Your Safeguards: Don't remove filters or accountability measures just because you're doing well. They're there for weak moments, not strong ones.

Stay Connected: Continue with community, accountability partners, and spiritual practices. Isolation is always risky.

Watch for Complacency: "I've got this" often precedes relapse. Maintain humility and dependence on Allah.

Remember Your Why: Keep your intention fresh. Why did you start this journey? That reason remains valid.

Handle Success Carefully: Sometimes people relapse after achievements—graduation, marriage, career success. The brain says "you've earned a reward." Don't let success become a trigger.

Long-term Mindset:

This isn't about counting days forever. It's about becoming someone who lives fully, worships freely, and doesn't need what the addiction falsely offered.

The goal isn't just abstinence. It's flourishing. A life of purpose, connection, worship, and genuine joy.

That life is available to you. You're building it now.
""",
            reflection: "Imagine yourself one year from now, free from this struggle. What does that person's life look like? How do they spend their time? How do they feel?",
            readTimeMinutes: 3
        ),

        // Day 30
        LessonContent(
            id: 30,
            title: "Graduation and Continuation",
            verse: "وَاعْبُدْ رَبَّكَ حَتَّىٰ يَأْتِيَكَ الْيَقِينُ",
            verseTranslation: "And worship your Lord until there comes to you the certainty (death).",
            verseReference: "Quran 15:99",
            content: """
You've completed 30 days of lessons. This is significant—but it's not an ending. It's a beginning.

What You've Learned:

You now understand addiction at biological, psychological, and spiritual levels. You have tools: tawbah, prayer, dhikr, fasting, lowering the gaze, environmental design, emotional awareness, healthy coping, support systems, habit building, and identity transformation.

You know your triggers and vulnerabilities. You have strategies for when urges hit and protocols for if you fall. You've developed self-compassion alongside self-discipline.

Most importantly, you've experienced that change is possible. Whatever your streak is today, you've proven you can do this.

The Ongoing Journey:

The verse commands worship "until certainty comes"—until death. This isn't depressing; it's clarifying. There's no finish line after which you coast. Growth and struggle continue. But so does Allah's help.

Your Next Steps:

1. Continue daily practices—don't stop just because lessons ended.
2. Review these lessons periodically—different insights will resonate at different stages.
3. Deepen what worked—if dhikr helped, go deeper into it. If journaling helped, expand it.
4. Help others when ready—your experience can guide someone starting where you were.
5. Stay humble—recovery is maintained, not completed.

A Final Reminder:

You started this journey seeking change. Allah honored that seeking with guidance. He brought you here, kept you reading, gave you the strength to continue.

Whatever happens next, remember: the door to Allah never closes. His mercy never runs out. You are not defined by your worst moments but by your sincere striving toward Him.

May Allah grant you steadfastness, protection, and the highest ranks of Jannah. May He make you among those who overcome their struggles and become beacons for others.

You've got this. And more importantly, Allah's got you.
""",
            reflection: "What is your commitment going forward? Write a letter to yourself that you can read when struggling—reminding yourself why you chose this path and how far you've come.",
            readTimeMinutes: 3
        )
    ]

    static func lesson(for day: Int) -> LessonContent? {
        allLessons.first { $0.id == day }
    }

    static var totalLessons: Int {
        allLessons.count
    }
}
