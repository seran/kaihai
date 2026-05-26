namespace :dev do
  desc "Load sample data for development (users, spaces, entries, comments)"
  task prime: :environment do
    raise "dev:prime is development-only" unless Rails.env.development?

    Account.singleton.update!(name: "Kaihai", tagline: "a quiet community")

    admin = User.find_or_create_by!(email_address: "admin@kaihai.local") do |user|
      user.handle = "admin"
      user.name = "Admin User"
      user.role = :admin
      user.password = "password"
    end

    regular = User.find_or_create_by!(email_address: "user@kaihai.local") do |user|
      user.handle = "user"
      user.name = "User"
      user.role = :user
      user.password = "password"
    end

    mock_spaces = [
      { name: "The Library",  handle: "library",  visibility: :open,    description: "A quiet corner for readers, recommendations, and slow conversations about books." },
      { name: "Garden Notes", handle: "garden",   visibility: :open,    description: "Plants, soil, seasons. Photos welcome. Pesticide debates not." },
      { name: "Daily Brew",   handle: "brew",     visibility: :open,    description: "Coffee, tea, ritual. Share what's in your cup this morning." },
      { name: "Field Recordings", handle: "field", visibility: :open,   description: "Sounds from where you are — birds, traffic, weather, rooms." },
      { name: "Inner Circle", handle: "inner",    visibility: :private, description: "An invite-only room for longtime members. Approval required." },
      { name: "Studio Hours", handle: "studio",   visibility: :private, description: "Working artists trading in-progress shots and feedback. Private by design." }
    ]

    mock_spaces.each do |attrs|
      space = Space.find_or_create_by!(handle: attrs[:handle]) do |s|
        s.name        = attrs[:name]
        s.visibility  = attrs[:visibility]
        s.description = attrs[:description]
        s.creator     = admin
      end

      space.subscriptions.find_or_create_by!(user: admin) do |sub|
        sub.role = :moderator
      end
    end

    brew = Space.find_by!(handle: "brew")
    brew.subscriptions.find_or_create_by!(user: regular)

    unless brew.entries.exists?
      Entry.create!(space: brew, author: admin,   entryable: Post.new(body: "Started the morning with a Hario V60 — Ethiopian Yirgacheffe, blueberry on the finish. What's in your cup?"))
      Entry.create!(space: brew, author: regular, entryable: Post.new(body: "Switched to a Bialetti this week. The ritual matters more than the extraction, honestly."))

      Entry.create!(space: brew, author: admin, entryable: Event.new(
        description: "Casual cupping. Bring two beans, we'll taste blind.",
        starts_at:   2.weeks.from_now.change(hour: 10),
        location:    "The Roastery, 3rd Ave"
      ))

      poll = Poll.new(question: "Favorite brew method on a slow Sunday?",
                      poll_options: [
                        PollOption.new(body: "Pour-over"),
                        PollOption.new(body: "French press"),
                        PollOption.new(body: "Moka pot"),
                        PollOption.new(body: "Cold brew")
                      ])
      Entry.create!(space: brew, author: regular, entryable: poll)
    end

    [
      {
        author:      admin,
        description: "Trying to plan the next bag. The single-origins we've sampled are listed below — pick whatever calls to you.",
        question:    "Which bean lands on the shelf next month?",
        options:     [ "Ethiopia · Yirgacheffe", "Colombia · Huila", "Kenya · Nyeri", "Guatemala · Antigua" ]
      },
      {
        author:   regular,
        question: "Milk or no milk?",
        options:  [ "Black, always", "Splash of milk", "Cappuccino territory" ]
      }
    ].each do |attrs|
      next if Poll.exists?(question: attrs[:question])
      Entry.create!(space: brew, author: attrs[:author], entryable: Poll.new(
        question:     attrs[:question],
        description:  attrs[:description],
        poll_options: attrs[:options].map { |body| PollOption.new(body: body) }
      ))
    end

    comment_scripts = {
      "Post" => [
        [ :other,  "Yirgacheffe is hard to beat in the morning. Try a 1:16 ratio if you haven't." ],
        [ :author, "Good call, I've been at 1:15 — will report back tomorrow." ],
        [ :other,  "The blueberry note really comes through when it's freshly roasted." ]
      ],
      "Event" => [
        [ :other,  "Count me in. I'll bring a Honduran natural and a washed Burundi." ],
        [ :author, "Perfect — we'll have a nice spread. Should we cap it at 8 people?" ],
        [ :other,  "8 sounds right, otherwise the kettle line gets ridiculous." ]
      ],
      "Poll" => [
        [ :other,  "Tough call. Pour-over on weekdays, French press on weekends here." ],
        [ :author, "That's a sensible split — same household, even." ],
        [ :other,  "Moka pot is criminally underrated, just saying." ]
      ]
    }

    brew.entries.includes(:entryable, :author).find_each do |entry|
      next if entry.comments.exists?

      script = comment_scripts[entry.entryable_type] or next
      base   = entry.created_at

      script.each_with_index do |(who, body), idx|
        commenter = who == :author ? entry.author : (entry.author == admin ? regular : admin)
        entry.comments.create!(
          user:       commenter,
          body:       body,
          created_at: base + (idx + 1) * 15.minutes,
          updated_at: base + (idx + 1) * 15.minutes
        )
      end
    end

    puts "✓ dev:prime complete — admin@kaihai.local / user@kaihai.local (password: password)"
  end
end
