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
                "Fitness::flexibility::Yoga", "Hobbies::creative_making::Photography",
                "Hobbies::practical_home_based::Cooking", "Hobbies::creative_making::Graphic Design",
                "Hobbies::intellectual_learning::Reading", "Media::tv_film::tv::The White Lotus",
                "Fitness::endurance::Cycling", "Fitness::flexibility::Pilates",
                "Media::music::artist::Taylor Swift", "Hobbies::outdoor_nature::Gardening",
                "Hobbies::general_casual::Trying New Things", "Ideas::philosophy_values::Mindfulness",
                "Hobbies::practical_home_based::Baking", "Hobbies::collecting_curation::Fashion / Styling",
                "Media::tv_film::tv::Stranger Things"
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
                "Hobbies::creative_making::Music Production", "Hobbies::creative_making::Playing an Instrument",
                "Hobbies::games_play::Video Games", "Hobbies::practical_home_based::Cooking",
                "Hobbies::social_community::Going to Concerts", "Fitness::sports_team::Basketball",
                "Media::music::artist::Drake", "Media::sports::NBA",
                "Media::games::Grand Theft Auto V", "Media::music::artist::Kendrick Lamar",
                "Media::music::Rap", "Media::podcasts::The Joe Rogan Experience",
                "Fitness::sports_team::Soccer"
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
                "Skills::general::Data Analysis", "Hobbies::games_play::Board Games",
                "Hobbies::creative_making::Coding Projects", "Hobbies::intellectual_learning::Reading",
                "Hobbies::games_play::Chess / Strategy Games", "Hobbies::intellectual_learning::Research / Learning",
                "Hobbies::practical_home_based::Baking", "Hobbies::intellectual_learning::Puzzles / Brain Games",
                "Ideas::philosophy_values::Rationalism", "Media::literature::book::Dune",
                "Media::tv_film::movie::Interstellar", "Media::tv_film::tv::Stranger Things",
                "Fitness::endurance::Hiking", "Ideas::philosophy_values::Systems Theory"
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
                "Hobbies::practical_home_based::Cooking", "Fitness::endurance::Cycling",
                "Fitness::sports_team::Soccer", "Fitness::endurance::Running",
                "Hobbies::outdoor_nature::Gardening", "Hobbies::general_casual::Trying New Things",
                "Media::music::artist::Bad Bunny", "Media::sports::Premier League",
                "Hobbies::social_community::Hosting / Dinner Parties", "Hobbies::practical_home_based::Baking",
                "Fitness::endurance::Hiking", "Hobbies::social_community::Socializing / Hanging Out",
                "Fitness::general::Active Lifestyle"
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
                "Hobbies::creative_making::Writing", "Hobbies::social_community::Volunteering",
                "Hobbies::intellectual_learning::Reading", "Hobbies::outdoor_nature::Nature Walks",
                "Hobbies::intellectual_learning::Language Learning", "Hobbies::social_community::Clubs / Organizations",
                "Ideas::society_culture::Social Justice", "Ideas::politics::Activism",
                "Ideas::religion_spirituality::Meditation", "Ideas::politics::Human Rights",
                "Media::literature::book::1984", "Media::literature::book::The Great Gatsby",
                "Ideas::society_culture::History", "Ideas::philosophy_values::Ethics",
                "Media::podcasts::The Daily", "Ideas::society_culture::Education"
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
                "Hobbies::practical_home_based::Home Projects", "Hobbies::practical_home_based::Repair / Fixing Things",
                "Fitness::endurance::Hiking", "Hobbies::outdoor_nature::Camping",
                "Hobbies::outdoor_nature::Fishing", "Hobbies::creative_making::Crafting / DIY",
                "Fitness::sports_team::Football", "Media::sports::NFL",
                "Fitness::sports_team::Ice Hockey", "Hobbies::practical_home_based::Organizing",
                "Fitness::endurance::Running", "Fitness::general::Active Lifestyle",
                "Media::podcasts::The Joe Rogan Experience"
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
                "Skills::general::Product Strategy", "Fitness::endurance::Dancing",
                "Hobbies::practical_home_based::Cooking", "Hobbies::social_community::Hosting / Dinner Parties",
                "Fitness::flexibility::Yoga", "Hobbies::collecting_curation::Fashion / Styling",
                "Hobbies::general_casual::Trying New Things", "Media::music::artist::Beyoncé",
                "Media::music::artist::Taylor Swift", "Media::tv_film::tv::Friends",
                "Ideas::philosophy_values::Self-improvement", "Fitness::flexibility::Barre",
                "Ideas::society_culture::Entrepreneurship", "Media::tv_film::tv::The White Lotus"
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
                "Hobbies::creative_making::Filmmaking / Video", "Hobbies::collecting_curation::Vinyl / Physical Media",
                "Hobbies::creative_making::Photography", "Hobbies::social_community::Going to Concerts",
                "Media::tv_film::tv::Seinfeld", "Media::tv_film::movie::Pulp Fiction",
                "Media::tv_film::Martin Scorsese", "Media::tv_film::Christopher Nolan",
                "Media::tv_film::movie::Interstellar", "Media::music::artist::The Weeknd",
                "Media::music::artist::Arctic Monkeys", "Media::games::Indie",
                "Media::podcasts::The Rewatchables", "Media::tv_film::Stanley Kubrick"
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
                "Hobbies::creative_making::Drawing / Illustration", "Hobbies::creative_making::Painting",
                "Hobbies::practical_home_based::Baking", "Hobbies::intellectual_learning::Reading",
                "Hobbies::collecting_curation::Thrifting / Antiquing", "Hobbies::creative_making::Graphic Design",
                "Media::tv_film::movie::Parasite", "Media::tv_film::movie::Howl's Moving Castle",
                "Hobbies::creative_making::Crafting / DIY", "Media::music::K-Pop",
                "Media::music::artist::SZA", "Hobbies::creative_making::Photography",
                "Hobbies::practical_home_based::Organizing"
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
                "Hobbies::games_play::Chess / Strategy Games", "Hobbies::intellectual_learning::Reading",
                "Hobbies::intellectual_learning::Research / Learning", "Hobbies::social_community::Volunteering",
                "Fitness::endurance::Running", "Hobbies::games_play::Board Games",
                "Hobbies::creative_making::Writing", "Ideas::society_culture::History",
                "Ideas::society_culture::Education", "Media::literature::book::1984",
                "Media::podcasts::The Daily", "Ideas::philosophy_values::Ethics",
                "Hobbies::intellectual_learning::Puzzles / Brain Games"
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
                "Hobbies::creative_making::Singing", "Hobbies::creative_making::Playing an Instrument",
                "Hobbies::creative_making::Writing", "Hobbies::social_community::Going to Concerts",
                "Media::music::artist::Björk", "Hobbies::social_community::Socializing / Hanging Out",
                "Media::music::artist::Billie Eilish", "Media::games::Indie",
                "Media::music::artist::Lana Del Rey", "Media::music::artist::Taylor Swift",
                "Hobbies::intellectual_learning::Language Learning", "Fitness::flexibility::Yoga"
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
                "Hobbies::creative_making::Coding Projects", "Fitness::sports_team::Soccer",
                "Hobbies::games_play::Video Games", "Hobbies::practical_home_based::Cooking",
                "Skills::general::Data Analysis", "Hobbies::games_play::Tabletop RPGs",
                "Media::sports::Premier League", "Media::games::The Witcher 3: Wild Hunt",
                "Media::games::Elden Ring", "Media::games::Minecraft",
                "Ideas::philosophy_values::Systems Theory", "Fitness::sports_team::Basketball"
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
                "Fitness::endurance::Running", "Hobbies::outdoor_nature::Nature Walks",
                "Hobbies::outdoor_nature::Gardening", "Hobbies::intellectual_learning::Research / Learning",
                "Hobbies::outdoor_nature::Birding / Wildlife", "Hobbies::outdoor_nature::Camping",
                "Hobbies::creative_making::Photography", "Ideas::politics::Environmental Justice",
                "Fitness::endurance::Hiking", "Fitness::endurance::Swimming",
                "Hobbies::intellectual_learning::Reading", "Ideas::philosophy_values::Mindfulness",
                "Media::podcasts::The Daily"
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
                "Hobbies::creative_making::Drawing / Illustration", "Hobbies::creative_making::Photography",
                "Hobbies::practical_home_based::Home Projects", "Fitness::endurance::Cycling",
                "Skills::general::Visual Design", "Hobbies::collecting_curation::Archiving / Cataloging",
                "Hobbies::creative_making::Graphic Design", "Ideas::society_culture::Urbanism",
                "Hobbies::intellectual_learning::Reading", "Media::tv_film::Christopher Nolan",
                "Media::tv_film::movie::Interstellar", "Hobbies::creative_making::Crafting / DIY"
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
                "Fitness::endurance::Running", "Fitness::endurance::Swimming",
                "Fitness::endurance::Walking", "Fitness::flexibility::Yoga",
                "Hobbies::practical_home_based::Cooking", "Hobbies::social_community::Socializing / Hanging Out",
                "Hobbies::social_community::Volunteering", "Fitness::flexibility::Pilates",
                "Fitness::general::Active Lifestyle", "Ideas::philosophy_values::Self-improvement",
                "Media::podcasts::Huberman Lab", "Ideas::philosophy_values::Mindfulness",
                "Fitness::endurance::Hiking"
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
                "Hobbies::creative_making::Graphic Design", "Hobbies::collecting_curation::Fashion / Styling",
                "Skills::general::Visual Design", "Hobbies::creative_making::Photography",
                "Hobbies::games_play::Video Games", "Hobbies::collecting_curation::Collecting (General)",
                "Ideas::society_culture::Internet Culture", "Media::music::K-Pop",
                "Media::music::artist::Travis Scott", "Media::music::artist::Kanye West",
                "Ideas::society_culture::Media & Pop Culture", "Media::games::Minecraft"
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
                "Hobbies::intellectual_learning::Reading", "Hobbies::creative_making::Writing",
                "Hobbies::social_community::Clubs / Organizations", "Hobbies::intellectual_learning::Research / Learning",
                "Hobbies::social_community::Hosting / Dinner Parties", "Hobbies::intellectual_learning::Puzzles / Brain Games",
                "Ideas::politics::Policy & Governance", "Ideas::politics::Civic Engagement",
                "Media::literature::book::1984", "Media::literature::book::Dune",
                "Media::literature::book::The Great Gatsby", "Media::literature::author::Jane Austen",
                "Media::literature::Fiction", "Media::podcasts::The Daily",
                "Ideas::society_culture::History"
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
                "Hobbies::creative_making::Music Production", "Hobbies::collecting_curation::Vinyl / Physical Media",
                "Hobbies::social_community::Going to Concerts", "Fitness::endurance::Dancing",
                "Hobbies::social_community::Socializing / Hanging Out", "Hobbies::games_play::Card Games",
                "Media::music::artist::Bad Bunny", "Media::music::artist::Rauw Alejandro",
                "Media::music::EDM", "Media::music::Electronic",
                "Media::music::Reggaeton", "Media::music::Rap"
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
                "Fitness::flexibility::Yoga", "Hobbies::practical_home_based::Baking",
                "Hobbies::outdoor_nature::Gardening", "Fitness::endurance::Walking",
                "Hobbies::practical_home_based::Organizing", "Hobbies::practical_home_based::Cooking",
                "Hobbies::outdoor_nature::Nature Walks", "Fitness::flexibility::Pilates",
                "Ideas::religion_spirituality::Meditation", "Ideas::philosophy_values::Mindfulness",
                "Ideas::philosophy_values::Self-improvement", "Ideas::society_culture::Health",
                "Ideas::religion_spirituality::Astrology", "Fitness::flexibility::Barre"
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
                "Hobbies::creative_making::Writing", "Hobbies::social_community::Socializing / Hanging Out",
                "Media::tv_film::tv::Saturday Night Live", "Media::podcasts::The Tim Dillon Show",
                "Hobbies::games_play::Board Games", "Hobbies::general_casual::Trying New Things",
                "Hobbies::games_play::Card Games", "Media::tv_film::tv::Seinfeld",
                "Media::tv_film::tv::Brooklyn Nine-Nine", "Media::tv_film::tv::It's Always Sunny in Philadelphia",
                "Media::podcasts::Conan O\u{2019}Brien Needs A Friend", "Hobbies::social_community::Going to Concerts"
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
                "Hobbies::collecting_curation::Fashion / Styling", "Hobbies::practical_home_based::Cooking",
                "Hobbies::social_community::Hosting / Dinner Parties", "Hobbies::creative_making::Photography",
                "Media::tv_film::tv::The White Lotus", "Hobbies::general_casual::Trying New Things",
                "Media::music::artist::Taylor Swift", "Media::music::artist::Beyoncé",
                "Media::tv_film::tv::Friends", "Media::tv_film::tv::Mad Men",
                "Fitness::flexibility::Yoga", "Fitness::endurance::Dancing"
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
                "Hobbies::creative_making::Crafting / DIY", "Hobbies::practical_home_based::Home Projects",
                "Hobbies::practical_home_based::Repair / Fixing Things", "Hobbies::practical_home_based::Cooking",
                "Hobbies::outdoor_nature::Camping", "Hobbies::outdoor_nature::Fishing",
                "Fitness::sports_team::Football", "Media::sports::NFL",
                "Fitness::sports_team::Baseball", "Media::podcasts::The Joe Rogan Experience",
                "Hobbies::collecting_curation::Collecting (General)", "Fitness::general::Active Lifestyle"
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
                "Hobbies::social_community::Volunteering", "Hobbies::outdoor_nature::Gardening",
                "Hobbies::social_community::Clubs / Organizations", "Hobbies::intellectual_learning::Reading",
                "Fitness::endurance::Walking", "Hobbies::practical_home_based::Baking",
                "Hobbies::social_community::Socializing / Hanging Out", "Ideas::society_culture::Social Justice",
                "Ideas::society_culture::Education", "Ideas::politics::Activism",
                "Ideas::politics::Human Rights", "Ideas::philosophy_values::Self-improvement",
                "Ideas::religion_spirituality::Meditation"
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
                "Hobbies::creative_making::Coding Projects", "Skills::general::Data Analysis",
                "Fitness::sports_team::Ice Hockey", "Hobbies::games_play::Video Games",
                "Fitness::endurance::Jogging", "Hobbies::intellectual_learning::Puzzles / Brain Games",
                "Media::sports::NHL", "Media::games::Elden Ring",
                "Media::games::Minecraft", "Media::games::The Witcher 3: Wild Hunt",
                "Ideas::philosophy_values::Systems Theory", "Media::games::Cyberpunk 2077"
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
                "Hobbies::creative_making::Painting", "Hobbies::creative_making::Drawing / Illustration",
                "Fitness::endurance::Dancing", "Hobbies::social_community::Going to Concerts",
                "Hobbies::collecting_curation::Thrifting / Antiquing", "Hobbies::creative_making::Photography",
                "Hobbies::creative_making::Crafting / DIY", "Media::music::artist::Björk",
                "Media::music::artist::FKA twigs", "Media::games::Indie",
                "Ideas::society_culture::Creative Arts", "Fitness::sports_individual::Skateboarding",
                "Ideas::society_culture::Media & Pop Culture"
            ],
            hasCompletedOnboarding: true
        )
    ]
}
