//
//  MockUsers.swift
//  Atopia-Lite
//
//  Created by Juniper Rodriguez on 3/5/26.
//

import Foundation

enum MockUsers {
    static let all: [LocalUser] = [
        LocalUser(
            id: "mock-01", username: "mkaplan", passwordHash: "",
            firstName: "Maya", lastName: "Kaplan",
            bio: "UX designer & plant mom. Always looking for new coffee spots.",
            latitude: 41.9088, longitude: -87.6796,
            city: "Chicago", neighborhood: "Wicker Park", state: "IL",
            phoneNumber: "3125550101",
            savedDatapoints: [
                "yoga", "photography", "cooking", "graphic-design", "reading",
                "the-white-lotus", "cycling", "pilates", "taylor-swift",
                "gardening", "trying-new-things", "mindfulness", "baking",
                "fashion-styling", "stranger-things"
            ],
            hasCompletedOnboarding: true
        ),
        LocalUser(
            id: "mock-02", username: "devontrae", passwordHash: "",
            firstName: "Devon", lastName: "Washington",
            bio: "Music producer. Basketball. South side forever.",
            latitude: 41.8231, longitude: -87.6177,
            city: "Chicago", neighborhood: "Bronzeville", state: "IL",
            phoneNumber: "3125550102",
            savedDatapoints: [
                "music-production", "playing-an-instrument", "video-games",
                "cooking", "going-to-concerts", "basketball", "drake",
                "nba", "grand-theft-auto-v", "kendrick-lamar", "rap",
                "the-joe-rogan-experience", "soccer"
            ],
            hasCompletedOnboarding: true
        ),
        LocalUser(
            id: "mock-03", username: "linazhou", passwordHash: "",
            firstName: "Lina", lastName: "Zhou",
            bio: "Data scientist by day, board game queen by night.",
            latitude: 41.8517, longitude: -87.6315,
            city: "Chicago", neighborhood: "Chinatown", state: "IL",
            phoneNumber: "3125550103",
            savedDatapoints: [
                "data-analysis", "board-games", "coding-projects", "reading",
                "chess-strategy-games", "research-learning", "baking",
                "puzzles-brain-games", "rationalism", "dune",
                "interstellar", "stranger-things", "hiking",
                "systems-theory"
            ],
            hasCompletedOnboarding: true
        ),
        LocalUser(
            id: "mock-04", username: "carlosf", passwordHash: "",
            firstName: "Carlos", lastName: "Fuentes",
            bio: "Chef at a taqueria. Love soccer and long bike rides along the lake.",
            latitude: 41.8565, longitude: -87.6637,
            city: "Chicago", neighborhood: "Pilsen", state: "IL",
            phoneNumber: "3125550104",
            savedDatapoints: [
                "cooking", "cycling", "soccer", "running", "gardening",
                "trying-new-things", "bad-bunny", "premier-league",
                "hosting-dinner-parties", "baking", "hiking",
                "socializing-hanging-out", "active-lifestyle"
            ],
            hasCompletedOnboarding: true
        ),
        LocalUser(
            id: "mock-05", username: "amirarose", passwordHash: "",
            firstName: "Amira", lastName: "Hassan",
            bio: "Poet. Activist. Tea enthusiast. Rogers Park is home.",
            latitude: 42.0087, longitude: -87.6685,
            city: "Chicago", neighborhood: "Rogers Park", state: "IL",
            phoneNumber: "3125550105",
            savedDatapoints: [
                "writing", "volunteering", "reading", "nature-walks",
                "language-learning", "clubs-organizations", "social-justice",
                "activism", "meditation", "human-rights", "1984",
                "the-great-gatsby", "history", "ethics",
                "the-daily", "education"
            ],
            hasCompletedOnboarding: true
        ),
        LocalUser(
            id: "mock-06", username: "jakemurphy", passwordHash: "",
            firstName: "Jake", lastName: "Murphy",
            bio: "Carpenter and weekend rock climber. Irish heritage runs deep.",
            latitude: 41.8379, longitude: -87.6506,
            city: "Chicago", neighborhood: "Bridgeport", state: "IL",
            phoneNumber: "3125550106",
            savedDatapoints: [
                "home-projects", "repair-fixing-things", "hiking",
                "camping", "fishing", "crafting-diy", "football",
                "nfl", "ice-hockey", "organizing", "running",
                "active-lifestyle", "the-joe-rogan-experience"
            ],
            hasCompletedOnboarding: true
        ),
        LocalUser(
            id: "mock-07", username: "priyasun", passwordHash: "",
            firstName: "Priya", lastName: "Sundaram",
            bio: "Product manager at a startup. Weekend dancer and foodie.",
            latitude: 41.9214, longitude: -87.6513,
            city: "Chicago", neighborhood: "Lincoln Park", state: "IL",
            phoneNumber: "3125550107",
            savedDatapoints: [
                "product-strategy", "dancing", "cooking",
                "hosting-dinner-parties", "yoga", "fashion-styling",
                "trying-new-things", "beyonce", "taylor-swift",
                "friends", "self-improvement", "barre",
                "entrepreneurship", "the-white-lotus"
            ],
            hasCompletedOnboarding: true
        ),
        LocalUser(
            id: "mock-08", username: "tylerj", passwordHash: "",
            firstName: "Tyler", lastName: "Johansson",
            bio: "Filmmaker. Vinyl collector. Always at the Music Box Theatre.",
            latitude: 41.9434, longitude: -87.6553,
            city: "Chicago", neighborhood: "Lakeview", state: "IL",
            phoneNumber: "3125550108",
            savedDatapoints: [
                "filmmaking-video", "vinyl-physical-media", "photography",
                "going-to-concerts", "seinfeld", "pulp-fiction",
                "martin-scorsese", "christopher-nolan", "interstellar",
                "the-weeknd", "arctic-monkeys", "indie",
                "the-rewatchables", "stanley-kubrick"
            ],
            hasCompletedOnboarding: true
        ),
        LocalUser(
            id: "mock-09", username: "nataliekim", passwordHash: "",
            firstName: "Natalie", lastName: "Kim",
            bio: "Illustrator & cat lady. You can find me at any Andersonville brunch.",
            latitude: 41.9798, longitude: -87.6688,
            city: "Chicago", neighborhood: "Andersonville", state: "IL",
            phoneNumber: "3125550109",
            savedDatapoints: [
                "drawing-illustration", "painting", "baking", "reading",
                "thrifting-antiquing", "graphic-design", "parasite",
                "howls-moving-castle", "crafting-diy", "k-pop",
                "sza", "photography", "organizing"
            ],
            hasCompletedOnboarding: true
        ),
        LocalUser(
            id: "mock-10", username: "marcusdavis", passwordHash: "",
            firstName: "Marcus", lastName: "Davis",
            bio: "High school teacher. Chess nerd. Hyde Park local.",
            latitude: 41.7943, longitude: -87.5907,
            city: "Chicago", neighborhood: "Hyde Park", state: "IL",
            phoneNumber: "3125550110",
            savedDatapoints: [
                "chess-strategy-games", "reading", "research-learning",
                "volunteering", "running", "board-games", "writing",
                "history", "education", "1984", "the-daily",
                "ethics", "puzzles-brain-games"
            ],
            hasCompletedOnboarding: true
        ),
        LocalUser(
            id: "mock-11", username: "sophiab", passwordHash: "",
            firstName: "Sophia", lastName: "Bianchi",
            bio: "Barista and aspiring songwriter. Logan Square nights.",
            latitude: 41.9234, longitude: -87.7083,
            city: "Chicago", neighborhood: "Logan Square", state: "IL",
            phoneNumber: "3125550111",
            savedDatapoints: [
                "singing", "playing-an-instrument", "writing",
                "going-to-concerts", "bj-rk", "socializing-hanging-out",
                "billie-eilish", "indie", "lana-del-rey",
                "taylor-swift", "language-learning", "yoga"
            ],
            hasCompletedOnboarding: true
        ),
        LocalUser(
            id: "mock-12", username: "okonkwo_e", passwordHash: "",
            firstName: "Emeka", lastName: "Okonkwo",
            bio: "Software engineer. Soccer league on weekends. Love a good jollof debate.",
            latitude: 41.9664, longitude: -87.6536,
            city: "Chicago", neighborhood: "Uptown", state: "IL",
            phoneNumber: "3125550112",
            savedDatapoints: [
                "coding-projects", "soccer", "video-games", "cooking",
                "data-analysis", "tabletop-rpgs", "premier-league",
                "the-witcher-3-wild-hunt", "elden-ring", "minecraft",
                "systems-theory", "basketball"
            ],
            hasCompletedOnboarding: true
        ),
        LocalUser(
            id: "mock-13", username: "rachelng", passwordHash: "",
            firstName: "Rachel", lastName: "Nguyen",
            bio: "Environmental scientist. Trail runner. Avondale dweller.",
            latitude: 41.9387, longitude: -87.7111,
            city: "Chicago", neighborhood: "Avondale", state: "IL",
            phoneNumber: "3125550113",
            savedDatapoints: [
                "running", "nature-walks", "gardening", "research-learning",
                "birding-wildlife", "camping", "photography",
                "environmental-justice", "hiking", "swimming",
                "reading", "mindfulness", "the-daily"
            ],
            hasCompletedOnboarding: true
        ),
        LocalUser(
            id: "mock-14", username: "danpetrov", passwordHash: "",
            firstName: "Daniel", lastName: "Petrov",
            bio: "Architect. Sketch everything I see. Ukrainian Village local.",
            latitude: 41.8988, longitude: -87.6828,
            city: "Chicago", neighborhood: "Ukrainian Village", state: "IL",
            phoneNumber: "3125550114",
            savedDatapoints: [
                "drawing-illustration", "photography", "home-projects",
                "cycling", "visual-design", "archiving-cataloging",
                "graphic-design", "urbanism", "reading",
                "christopher-nolan", "interstellar", "crafting-diy"
            ],
            hasCompletedOnboarding: true
        ),
        LocalUser(
            id: "mock-15", username: "jessicataylor", passwordHash: "",
            firstName: "Jessica", lastName: "Taylor",
            bio: "Nurse and marathon runner. Humboldt Park is my happy place.",
            latitude: 41.9022, longitude: -87.7228,
            city: "Chicago", neighborhood: "Humboldt Park", state: "IL",
            phoneNumber: "3125550115",
            savedDatapoints: [
                "running", "swimming", "walking", "yoga", "cooking",
                "socializing-hanging-out", "volunteering", "pilates",
                "active-lifestyle", "self-improvement", "huberman-lab",
                "mindfulness", "hiking"
            ],
            hasCompletedOnboarding: true
        ),
        LocalUser(
            id: "mock-16", username: "kenji_m", passwordHash: "",
            firstName: "Kenji", lastName: "Matsuda",
            bio: "Graphic designer. Sneakerhead. Old Town explorer.",
            latitude: 41.9117, longitude: -87.6376,
            city: "Chicago", neighborhood: "Old Town", state: "IL",
            phoneNumber: "3125550116",
            savedDatapoints: [
                "graphic-design", "fashion-styling", "visual-design",
                "photography", "video-games", "collecting-general",
                "internet-culture", "k-pop", "travis-scott",
                "kanye-west", "media-pop-culture", "minecraft"
            ],
            hasCompletedOnboarding: true
        ),
        LocalUser(
            id: "mock-17", username: "oliviagrant", passwordHash: "",
            firstName: "Olivia", lastName: "Grant",
            bio: "Grad student in public policy. Book club organizer. South Loop.",
            latitude: 41.8567, longitude: -87.6254,
            city: "Chicago", neighborhood: "South Loop", state: "IL",
            phoneNumber: "3125550117",
            savedDatapoints: [
                "reading", "writing", "clubs-organizations",
                "research-learning", "hosting-dinner-parties",
                "puzzles-brain-games", "policy-governance",
                "civic-engagement", "1984", "dune",
                "the-great-gatsby", "jane-austen", "fiction",
                "the-daily", "history"
            ],
            hasCompletedOnboarding: true
        ),
        LocalUser(
            id: "mock-18", username: "ajimenez", passwordHash: "",
            firstName: "Alejandro", lastName: "Jimenez",
            bio: "DJ and record store clerk. Little Village raised.",
            latitude: 41.8456, longitude: -87.7132,
            city: "Chicago", neighborhood: "Little Village", state: "IL",
            phoneNumber: "3125550118",
            savedDatapoints: [
                "music-production", "vinyl-physical-media",
                "going-to-concerts", "dancing", "socializing-hanging-out",
                "card-games", "bad-bunny", "rauw-alejandro",
                "edm", "electronic", "reggaeton", "rap"
            ],
            hasCompletedOnboarding: true
        ),
        LocalUser(
            id: "mock-19", username: "haileyross", passwordHash: "",
            firstName: "Hailey", lastName: "Ross",
            bio: "Yoga instructor and vegan baker. Ravenswood vibes.",
            latitude: 41.9743, longitude: -87.6745,
            city: "Chicago", neighborhood: "Ravenswood", state: "IL",
            phoneNumber: "3125550119",
            savedDatapoints: [
                "yoga", "baking", "gardening", "walking", "organizing",
                "cooking", "nature-walks", "pilates", "meditation",
                "mindfulness", "self-improvement", "health",
                "astrology", "barre"
            ],
            hasCompletedOnboarding: true
        ),
        LocalUser(
            id: "mock-20", username: "isaacw", passwordHash: "",
            firstName: "Isaac", lastName: "Williams",
            bio: "Stand-up comedian. Trivia night champion. Edgewater local.",
            latitude: 41.9833, longitude: -87.6600,
            city: "Chicago", neighborhood: "Edgewater", state: "IL",
            phoneNumber: "3125550120",
            savedDatapoints: [
                "writing", "socializing-hanging-out", "saturday-night-live",
                "the-tim-dillon-show", "board-games", "trying-new-things",
                "card-games", "seinfeld", "brooklyn-nine-nine",
                "it-s-always-sunny-in-philadelphia", "conan-obrien-needs-a-friend",
                "going-to-concerts"
            ],
            hasCompletedOnboarding: true
        ),
        LocalUser(
            id: "mock-21", username: "giuliap", passwordHash: "",
            firstName: "Giulia", lastName: "Parisi",
            bio: "Fashion buyer. Italian food snob. Gold Coast glamour.",
            latitude: 41.9035, longitude: -87.6282,
            city: "Chicago", neighborhood: "Gold Coast", state: "IL",
            phoneNumber: "3125550121",
            savedDatapoints: [
                "fashion-styling", "cooking", "hosting-dinner-parties",
                "photography", "the-white-lotus", "trying-new-things",
                "taylor-swift", "beyonce", "friends",
                "mad-men", "yoga", "dancing"
            ],
            hasCompletedOnboarding: true
        ),
        LocalUser(
            id: "mock-22", username: "benmiller", passwordHash: "",
            firstName: "Ben", lastName: "Miller",
            bio: "Woodworker. Homebrewer. Back of the Yards craftsman.",
            latitude: 41.8134, longitude: -87.6577,
            city: "Chicago", neighborhood: "Back of the Yards", state: "IL",
            phoneNumber: "3125550122",
            savedDatapoints: [
                "crafting-diy", "home-projects", "repair-fixing-things",
                "cooking", "camping", "fishing", "football",
                "nfl", "baseball", "the-joe-rogan-experience",
                "collecting-general", "active-lifestyle"
            ],
            hasCompletedOnboarding: true
        ),
        LocalUser(
            id: "mock-23", username: "tanisha_j", passwordHash: "",
            firstName: "Tanisha", lastName: "Jackson",
            bio: "Social worker. Community garden organizer. Chatham pride.",
            latitude: 41.7410, longitude: -87.6126,
            city: "Chicago", neighborhood: "Chatham", state: "IL",
            phoneNumber: "3125550123",
            savedDatapoints: [
                "volunteering", "gardening", "clubs-organizations",
                "reading", "walking", "baking",
                "socializing-hanging-out", "social-justice",
                "education", "activism", "human-rights",
                "self-improvement", "meditation"
            ],
            hasCompletedOnboarding: true
        ),
        LocalUser(
            id: "mock-24", username: "ryanflynn", passwordHash: "",
            firstName: "Ryan", lastName: "Flynn",
            bio: "Data engineer. Pickup hockey. Irving Park regular.",
            latitude: 41.9537, longitude: -87.7364,
            city: "Chicago", neighborhood: "Irving Park", state: "IL",
            phoneNumber: "3125550124",
            savedDatapoints: [
                "coding-projects", "data-analysis", "ice-hockey",
                "video-games", "jogging", "puzzles-brain-games",
                "nhl", "elden-ring", "minecraft",
                "the-witcher-3-wild-hunt", "systems-theory",
                "cyberpunk-2077"
            ],
            hasCompletedOnboarding: true
        ),
        LocalUser(
            id: "mock-25", username: "zoesanchez", passwordHash: "",
            firstName: "Zoe", lastName: "Sanchez",
            bio: "Muralist. Roller skater. Bucktown creative.",
            latitude: 41.9207, longitude: -87.6804,
            city: "Chicago", neighborhood: "Bucktown", state: "IL",
            phoneNumber: "3125550125",
            savedDatapoints: [
                "painting", "drawing-illustration", "dancing",
                "going-to-concerts", "thrifting-antiquing", "photography",
                "crafting-diy", "bj-rk", "fka-twigs",
                "indie", "creative-arts", "skateboarding",
                "media-pop-culture"
            ],
            hasCompletedOnboarding: true
        )
    ]
}
