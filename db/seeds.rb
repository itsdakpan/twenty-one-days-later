require "open-uri"

# Demo data: a handful of friends, three groups at different stages, check-ins and comments.
# Log in with demo@21dayslater.app / password123

puts "Cleaning database..."
[Comment, GoalCompletion, Goal, GroupMembership, Group, User].each(&:destroy_all)

people = [
  { first_name: "Dylan",   last_name: "Akpan",    username: "dylan",   email: "demo@21dayslater.app" },
  { first_name: "Amara",   last_name: "Okafor",   username: "amarao" },
  { first_name: "Kenji",   last_name: "Watanabe", username: "kenji_w" },
  { first_name: "Priya",   last_name: "Raman",    username: "priyar" },
  { first_name: "Tomás",   last_name: "Herrera",  username: "tomash" },
  { first_name: "Freya",   last_name: "Lindqvist", username: "freyal" },
  { first_name: "Malik",   last_name: "Bennett",  username: "malikb" }
]

puts "Creating users..."
users = people.map do |person|
  user = User.create!(
    person.merge(email: person[:email] || "#{person[:username]}@example.com", password: "password123")
  )
  begin
    avatar = URI.open("https://api.dicebear.com/9.x/notionists/png?seed=#{person[:username]}&backgroundColor=ece9f3", read_timeout: 5)
    user.photo.attach(io: avatar, filename: "#{person[:username]}.png", content_type: "image/png")
  rescue StandardError => e
    puts "  No avatar for #{person[:username]} (#{e.class}: #{e.message}), using initials"
    # Don't leave an attachment behind that points at a file which never uploaded.
    user.reload.photo.detach if user.photo.attached?
  end
  user
end
dylan, amara, kenji, priya, tomas, freya, malik = users

def build_group(name:, owner:, members:, habit:, reason:, start_date:, rates:)
  group = Group.create!(name: name, user: owner)
  ([owner] + members).each { |member| group.group_memberships.create!(user: member) }
  goal = group.goals.create!(name: habit, reason: reason, start_date: start_date, user: owner)

  days_so_far = [(Date.current - start_date).to_i + 1, Goal::CHALLENGE_DAYS].min
  ([owner] + members).zip(rates).each do |member, rate|
    days_so_far.times do |i|
      next unless rand < rate
      GoalCompletion.create!(user: member, goal: goal, date: start_date + i.days)
    end
  end
  group
end

srand(21)
puts "Creating groups..."
runners = build_group(
  name: "Morning runners", owner: dylan, members: [amara, kenji, freya],
  habit: "Run 3km before work", reason: "Training for the Manchester half in spring.",
  start_date: Date.current - 12, rates: [0.92, 0.85, 0.6, 0.75]
)
readers = build_group(
  name: "Okafor family", owner: amara, members: [dylan, priya, malik],
  habit: "Read 20 pages a day", reason: "Less scrolling, more books. Loser picks the next film night.",
  start_date: Date.current - 20, rates: [1.0, 0.9, 1.0, 0.8]
)
build_group(
  name: "Flat 4B", owner: dylan, members: [tomas, priya],
  habit: "Cook dinner at home", reason: "Save money and stop ordering takeaway five nights a week.",
  start_date: Date.current + 4, rates: [0, 0, 0]
)

# Dylan finished every day in the reading group.
readers.goal.tap do |goal|
  Goal::CHALLENGE_DAYS.times { |i| GoalCompletion.find_or_create_by!(user: dylan, goal: goal, date: goal.start_date + i.days) }
end

puts "Adding comments..."
[
  [runners, kenji, "Rain this morning. Went anyway. Regret nothing.", 3, 30.hours],
  [runners, amara, "Day 10 done, first time I didn't want to stop at 2km", 4, 5.hours],
  [runners, freya, "Missed yesterday with a cold, back on it tomorrow", 2, 3.hours],
  [readers, malik, "Finished my book. Starting the next one tonight.", 2, 2.days],
  [readers, priya, "One day to go and I'm keeping this going after", 3, 6.hours]
].each do |group, user, message, likes, ago|
  group.comments.create!(user: user, message: message, likes: likes, created_at: ago.ago)
end

puts "Done. Log in with demo@21dayslater.app / password123"
