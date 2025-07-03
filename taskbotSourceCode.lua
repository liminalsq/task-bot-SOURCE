local Players = game:GetService("Players")
local PathfindingService = game:GetService("PathfindingService")
local RunService = game:GetService("RunService")
local TextChatService = game:GetService("TextChatService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LOCAL_PLAYER = Players.LocalPlayer
local CHARACTER = LOCAL_PLAYER.Character or LOCAL_PLAYER.CharacterAdded:Wait()
local HUMANOID = CHARACTER:WaitForChild("Humanoid")
local HRP = CHARACTER:WaitForChild("HumanoidRootPart")

local WHITELIST = { ["PlayerEater9"] = true, ["RealPerson_0010"] = true, ["RealPerson_2005"] = true, ["MEUGLYTHEPERSON"] = true }

local currentTarget = nil
local currentCommander = nil
local chasing = false
local following = false
local trolling = false
local nonsenseMode = false
local copyingPlayer = nil
local strafeActive = false
local wandering = false
local staring = false
local path
local lastTargetPos

local bodyGyro = Instance.new("BodyGyro")
bodyGyro.Name = "AimGyro"
bodyGyro.MaxTorque = Vector3.new(0, math.huge, 0)
bodyGyro.P = 100000
bodyGyro.D = 1000
bodyGyro.CFrame = HRP.CFrame
bodyGyro.Parent = ReplicatedStorage

local funFacts = {
	"Octopuses have three hearts.",
	"Bananas are berries but strawberries are not.",
	"The Eiffel Tower can be 15 cm taller during the summer.",
	"The sun can give you vitamin D.",
	"Sharks have been around longer than trees.",
	"Honey never spoils.",
	"A group of flamingos is called a flamboyance.",
	"Taking breaks every now and then can boost your immune system.",
	"The tiny pocket in jeans was designed to store pocket watches.",
	"Your heart beats an average of 100,000 times each day.",
	"The longest English word is 189,819 letters long.",
	"The Eiffel Tower was originally made for Barcelona.",
	"The real name for a hashtag is an octothorpe.",
	"The world’s longest concert lasted 453 hours.",
	"A fear of long words is called Hippopotomonstrosesquippedaliophobia (Whoever came up with this is a monster).",
	"Karate originated in India.",
	"The infinity sign is called a lemniscate.",
	"Children grow faster during springtime.",
	"It takes an interaction of 72 muscles to produce human speech.",
	"Sailors once thought wearing gold earrings improved eyesight.",
	"Our eyes are always the same size from birth, but our nose and ears never stop growing.",
	"Your skull is made up of 29 different bones.",
	"Every hour more than one billion cells in the body must be replaced.",
	"Women's hearts typically beat faster than men's hearts.",
	"Adults laugh only about 15 to 100 times a day, while six-year-olds laugh an average of 300 times a day.",
	"Children have more taste buds than adults.",
	"Right handed people tend to chew food on the right side and lefties chew on the left.",
	"A cucumber consists of 96% water.",
	"Vanilla is used to make chocolate.",
	"One lump of sugar is equivalent to three feet of sugar cane.",
	"A lemon contains more sugar than a strawberry.",
	"Until the nineteenth century, solid blocks of tea were used as money in Siberia.",
	"Wild camels once roamed Arizona's deserts.",
	"New York was the first state to require cars to have license plates.",
	"Miami installed the first ATM for rollerbladers.",
	"Hawaii has its own time zone.",
	"Oregon has more ghost towns than any other US state.",
	"Cleveland, OH is home to the first electric traffic lights.",
	"South Carolina is home to the first tea farm in the U.S.",
	"The term rookies comes from a Civil War term, reckie, which was short for recruit.",
	"Taft was the heaviest U.S. President at 329lbs; Madison was the smallest at 100lbs.",
	"Harry Truman was the last U.S. President to not have a college degree.",
	"Abraham Lincoln was the tallest U.S. President at 6'4', while James Madison was the shortest at 5'4'.",
	"Franklin Roosevelt was related to 5 U.S. Presidents by blood and 6 by marriage.",
	"Thomas Jefferson invented the coat hanger.",
	"Theodore Roosevelt had a pet bear while in office.",
	"President Warren G. Harding once lost white house china in a poker game.",
	"Ulysses Simpson Grant was fined $20.00 for speeding on his horse.",
	"President William Taft weighed over 300 lbs and once got stuck in the white house bathtub.",
	"President William McKinley had a pet parrot that he named “Washington Post.”",
	"Harry S. Truman's middle name is S.",
	"The youngest U.S. president to be in office was Theodore Roosevelt at age 42.",
	"Most Koala bears can sleep up to 22 hours a day.",
	"In 1859, 24 rabbits were released in Australia. Within 6 years, the population grew to 2 million.",
	"Butterflies can taste with their hind feet.",
	"A strand from the web of a golden spider is as strong as a steel wire of the same size.",
	"The bumblebee bat is one of the smallest mammals on Earth. It weighs less than a penny.",
	"The Valley of Square Trees in Panama is the only known place in the world where trees have rectangular trunks.",
	"The original Cinderella was Egyptian and wore fur slippers.",
	"The plastic things on the end of shoelaces are called aglets.",
	"Neckties were first worn in Croatia, which is why they were called cravats.",
	"Barbie's full name is Barbara Millicent Roberts.",
	"The first TV toy commercial aired in 1946 for Mr. Potato Head.",
	"If done perfectly, any Rubik's Cube combination can be solved in 17 turns.",
	"The side of a hammer is called a cheek.",
	"In Athens, Greece, a driver's license can be taken away by law if the driver is deemed either unbathed or poorly dressed.",
	"In Texas, it is illegal to graffiti someone's cow.",
	"Less than 3% of the water on Earth is fresh.",
	"A cubic mile of fog is made up of less than a gallon of water.",
	"The Saturn V moon rocket consumed 15 tons of fuel per second.",
	"A manned rocket can reach the moon in less time than it took a stagecoach to travel the length of England.",
	"At room temperature, the average air molecule travels at the speed of a rifle bullet.",
	"The lollipop was named after one of the most famous Racehorses in the early 1900s, Lolly Pop.",
	"Buzz Aldrin was one of the first men on the moon. His mother's maiden name was also Moon.",
	"Maine is the only state with a one-syllable name.",
	"The highest denomination issued by the U.S. was the 100,000 dollar bill.",
	"The White House was originally called the President's Palace. It became The White House in 1901.",
	"George Washington was the only unanimously elected President.",
	"John Adams was the only President to be defeated by his Vice President, Thomas Jefferson.",
	"New York City has over 800 miles of subway track.",
	"Manatees' eyes close in a circular motion, much like the aperture of a camera.",
	"Even though it is nearly twice as far away from the Sun as Mercury, Venus is by far the hottest planet.",
	"The nothingness of a black hole generates a sound in the key of B flat.",
	"Horses can't vomit.",
	"Babies are born with about 300 separate bones, but adults have 206.",
	"Newborn babies cannot cry tears for at least three weeks.",
	"A day on Venus lasts longer than a year on Venus.",
	"Squirrels lose more than half of the nuts they hide.",
	"The penny was the first U.S. coin to feature the likeness of an actual person.",
	"Forty percent of twins invent their own language.",
	"In South Korea, it is against the rules for a professional baseball player to wear cabbage leaves inside of his hat.",
	"Curly hair follicles are oval, while straight hair follicles are round.",
	"George Washington had false teeth made of gold, ivory, and lead - but never wood.",
	"Napoleon Bonaparte was actually not short. At 5' 7', he was average height for his time.",
	"The Inca built the largest and wealthiest empire in South America, but had no concept of money.",
	"It is against the law to use 'The Star Spangled Banner' as dance music in Massachusetts.",
	"Queen Cleopatra of Egypt was not actually Egyptian.",
	"Early football fields were painted with both horizontal and vertical lines, creating a pattern that resembled a gridiron.",
	"Two national capitals are named after U.S. presidents: Washington, D.C., and Monrovia, the capital of Liberia.",
	"The first spam message was transmitted over telegraph wires in 1864.",
	"A pearl can be dissolved by vinegar.",
	"Queen Isabella I of Spain, who funded Columbus' voyage across the ocean, claimed to have only bathed twice in her life.",
	"The longest attack of hiccups ever lasted 68 years.",
	"A bolt of lightning can reach temperatures hotter than 50,000 degrees Fahrenheit - five times hotter than the sun.",
	"At the deepest point in the ocean, the water pressure is equivalent to having about 50 jumbo jets piled on top of you.",
	"In only 7.6 billion years, the sun will reach its maximum size and will shine 3,000 times brighter.",
	"The state of Alabama once financed the construction of a bridge by holding a rooster auction.",
	"Federal law once allowed the government to quarantine people who came in contact with aliens.",
	"There are 21 'secret' highways that are part of the Interstate Highway System. They are not identified as such by road signs.",
	"The aphid insect is born pregnant.",
	"John Wilkes Booth's brother saved the life of Abraham Lincoln's son.",
	"It is illegal in the United Kingdom to handle salmon in suspicious circumstances.",
	"It is illegal to play annoying games in the street in the United Kingdom.",
	"Tennis was originally played with bare hands.",
	"-40 degrees Fahrenheit is the same temperatures as -40 degrees Celsius.",
	"U.S. President John Tyler had 15 children, the last of which was born when he was 70 years old.",
	"Dolphins are unable to smell.",
	"Charlie Chaplin failed to make the finals of a Charlie Chaplin look-alike contest.",
	"The name of the city of Portland, Oregon was decided by a coin toss. The name that lost was Boston.",
	"The letter J is the only letter in the alphabet that does not appear anywhere on the periodic table of the elements.",
	"'K' was chosen to stand for a strikeout in baseball because 'S' was being used to denote a sacrifice.",
	"A dimpled golf ball produces less drag and flies farther than a smooth golf ball.",
	"When grazing or resting, cows tend to align their bodies with the magnetic north and south poles.",
	"President Chester A. Arthur owned 80 pairs of pants, which he changed several times per day.",
	"Cows do not have upper front teeth.",
	"Between 1979 and 1999, the planet Neptune was farther from the Sun than Pluto. This won't happen again until 2227.",
	"When creating a mummy, Ancient Egyptians removed the brain by inserting a hook through the nostrils.",
	"All of the major candidates in the 1992, 1996, and 2008 U.S. presidential elections were left-handed.",
	"In Switzerland, it is illegal to own only one guinea pig because they are prone to loneliness.",
	"The first American gold rush happened in North Carolina, not California.",
	"To make one pound of honey, a honeybee must tap about two million flowers.",
	"Chicago is named after smelly garlic that once grew in the area.",
	"The Chicago river flows backwards; the flow reversal project was completed in 1900.",
	"The patent for the fire hydrant was destroyed in a fire.",
	"Powerful earthquakes can make the Earth spin faster.",
	"Baby bunnies are called kittens.",
	"A group of flamingos is called a flamboyance.",
	"Sea otters hold each other’s paws while sleeping so they don’t drift apart.",
	"Gentoo penguins propose to their life mates with a pebble.",
	"Male pups will intentionally let female pups “win” when they play-fight so they can get to know them better.",
	"A cat’s nose is ridged with a unique pattern, just like a human fingerprint.",
	"A group of porcupines is called a prickle.",
	"99% of our solar system's mass is the sun.",
	"More energy from the sun hits Earth every hour than the planet uses in a year.",
	"If two pieces of the same type of metal touch in outer space, they will bond together permanently.",
	"Just a sugar cube of neutron star matter would weigh about one hundred million tons on Earth.",
	"A soup can full of neutron star material would have more mass than the Moon.",
	"Ancient Chinese warriors would show off to their enemies before battle, by juggling.",
	"OMG was added to dictionaries in 2011, but its first known use was in 1917.",
	"In the state of Arizona, it is illegal for donkeys to sleep in bathtubs.",
	"The glue on Israeli postage stamps is certified kosher.",
	"Rats and mice are ticklish, and even laugh when tickled.",
	"Norway once knighted a penguin.",
	"The King of Hearts is the only king without a mustache.",
	"It is illegal to sing off-key in North Carolina.",
	"Forty is the only number whose letters are in alphabetical order.",
	"One is the only number with letters in reverse alphabetical order.",
	"Strawberries are grown in every state in the U.S. and every province in Canada.",
	"The phrase, “You’re a real peach” originated from the tradition of giving peaches to loved ones.",
	"At latitude 60° south, it is possible to sail clear around the world without touching land.",
	"Interstate 90 is the longest U.S. Interstate Highway with over 3,000 miles from Seattle, WA to Boston, MA.",
	"DFW Airport in Texas is larger than the island of Manhattan.",
	"Benjamin Franklin invented flippers.",
	"Miami installed the first ATM for inline skaters.",
	"Indonesia is made up of more than 17,000 islands.",
	"Giraffes have the same number of vertebrae as humans: 7.",
	"The official taxonomic classification for llamas is Llama glama.",
	"Remove all the space between its atoms and Earth would be the size of a baseball.",
	"The soil on Mars is rust color because it's full of rust.",
	"Sound travels up to 15 times faster through steel than air, at speeds up to 19,000 feet per second.",
	"Humans share 50% of their DNA with bananas.",
	"Maine is the closest U.S. state to Africa.",
	"An octopus has three hearts.",
	"Only 12 U.S. presidents have been elected to office for two terms and served those two terms.",
	"Franklin D. Roosevelt was elected to office for four terms prior to the 22nd Amendment.",
	"John F. Kennedy, at 43, was the youngest elected president, and Ronald Reagan, at 73, the oldest.",
	"James Buchanan is the only bachelor to be elected president.",
	"Eight presidents have died while in office.",
	"Bill Clinton was born William Jefferson Blythe III, but took his stepfather’s last name when his mother remarried.",
	"Prior to the 12th Amendment in 1804, the presidential candidate who received the second highest number of electoral votes was vice president.",
	"George Washington was a successful liquor distributor, making rye whiskey, apple brandy, and peach brandy in his Mount Vernon distillery.",
	"Thomas Jefferson and John Adams chipped off a piece of Shakespeare's chair as a souvenir when they visited his home in 1786.",
	"George Washington started losing his permanent teeth in his 20s and had only one natural tooth by the time he was president.",
	"George Washington had false teeth made from many different materials, including an elephant tusk and hippopotamus ivory.",
	"George Washington protected his beloved horses from losing their teeth by making sure they were brushed regularly.",
	"John Quincy Adams regularly skinny-dipped in the Potomac River.",
	"Calvin Coolidge was so shy, he was nicknamed “Silent Cal.”",
	"Calvin Coolidge loved to wear a cowboy hat and ride his mechanical horse.",
	"President Herbert Hoover invented “Hooverball” (a cross between volleyball and tennis using a medicine ball), which he played with his cabinet members.",
	"Andrew Jackson was involved in as many as 100 duels, many of which were fought to defend the honor of his wife, Rachel.",
	"Martin Van Buren's nickname was 'Old Kinderhook' because he was raised in Kinderhook, N.Y.",
	"James Buchanan bought slaves in Washington, D.C., and quietly freed them in Pennsylvania.",
	"Abraham Lincoln was only defeated once in about 300 wrestling matches, making it to the Wrestling Hall of Fame with honors as 'Outstanding American.'",
	"In his youth, President Andrew Johnson apprenticed as a tailor.",
	"Ulysses S. Grant smoked at least 20 cigars a day; citizens sent him at least 10,000 boxes in gratitude after winning the Battle of Shiloh.",
	"Not only was James Garfield ambidextrous, he could write Latin with one hand and Greek with the other at the same time.",
	"Benjamin Harrison was the first president to have electricity in the White House; however, he was so scared of getting electrocuted, he’d never touch the light switches himself.",
	"William McKinley almost always wore a red carnation on his lapel as a good-luck charm.",
	"Herbert Hoover's son had two pet alligators that were occasionally permitted to run loose throughout the White House.",
	"Jimmy Carter filed a report for a UFO sighting in 1973, calling it “the darndest thing I’ve ever seen.”",
	"Bill Clinton's face is so symmetrical that he ranked in facial symmetry alongside male models.",
	"In 1916, Jeannette Rankin of Montana became the first woman elected to Congress.",
	"Gerald Ford was the only president and vice president never to be elected to either office.",
	"Victoria Woodhull, in 1872, was the first woman to run for the U.S. presidency.",
	"James Monroe received every electoral vote but one in the 1820 election.",
	"There are only three requirements to become U.S. president: must be 35, a natural-born U.S. citizen, and have resided in the U.S. for at least 14 years.",
	"To cut groundskeeping costs during World War I, President Woodrow Wilson brought a flock of sheep to trim the White House grounds.",
	"Rutherford B. Hayes was the first president to use a phone, and his phone number was extremely easy to remember – simply “1.”",
	"Martin Van Buren was the first president born a U.S. citizen; all presidents before him were British.",
	"Andrew Jackson's pet parrot Poll was removed from his funeral for cursing.",
	"There has never been a U.S. president whose name started with the common letter S.",
	"Abraham Lincoln is the only U.S. president who was also a licensed bartender.",
	"Barack Obama is called the 44th president, but is actually the 43rd because Grover Cleveland is counted twice, as he was elected for two terms.",
	"Four times in U.S history has a presidential candidate won the popular vote but lost the election.",
	"President Herbert Hoover and his wife were fluent in Mandarin Chinese and would use it in the White House to speak privately to each other.",
	"November was chosen to be election month because it fell between harvest and brutal winter weather.",
	"Six of the last 12 U.S. presidents have been left-handed, far greater than the national average of lefties (10%).",
	"William Henry Harrison owned a pet goat while in office.",
	"John Adams had a horse named Cleopatra.",
	"James Madison had a pet parrot who outlived him and his wife.",
	"John Quincy Adams' wife raised silkworms.",
	"Martin Van Buren was given two tiger cubs while he was president.",
	"William Harrison had a billy goat at the White House.",
	"Franklin Pierce was gifted two small 'sleeve dogs' – he kept one and gave the other to Jefferson Davis.",
	"Abraham Lincoln's son had a pet turkey, which he gave a pardon so it wasn't killed and eaten.",
	"James Garfield had a dog appropriately named Veto.",
	"William Taft liked milk so much that he had cows graze on the White House lawn, Pauline being the last in history to graze there.",
	"Calvin Coolidge had a bulldog named Boston Beans, a terrier named Peter Pan, and a pet raccoon.",
	"John Kennedy had a pony named Macaroni.",
	"Lyndon Johnson had two beagles, named Him and Her, for which he was criticized for picking up by their ears.",
	"Jimmy Carter had a dog named Grits, a gift given to his daughter Amy.",
	"Bill Clinton had a cat named Socks, which was the first presidential pet to have its own website.",
	"Woodrow Wilson passed the Georgia Bar Exam despite not finishing law school; he also has a PhD.",
	"President Zachary Taylor's nickname was 'Old Rough and Ready' because of his famed war career.",
	"Andrew Jackson was once given a 1,400-pound cheese wheel as a gift, which he served at his outgoing President's Reception.",
	"Blueberry jelly beans were created for Ronald Reagan’s presidential inauguration in 1981.",
	"Dwight D. Eisenhower was the first Texas-born president.",
	"Lyndon Johnson's family all had the initials LBJ.",
	"Thomas Jefferson was convinced that if he soaked his feet in a bucket of cold water every day, he’d never get sick.",
	"Gerald Ford worked as a fashion model during college and actually appeared on the cover of Cosmopolitan.",
	"Dwight Eisenhower was the only president to serve in both World War I and World War II.",
	"Jimmy Carter was the first president to be born in a hospital.",
	"Calvin Coolidge liked to have his head rubbed with petroleum jelly while eating breakfast in bed, believing it was good for his health.",
	"A portion of Grover Cleveland's jaw was artificial, composed of vulcanized rubber.",
	"Russia and the United States are less than three miles apart.",
	"John Adams and Thomas Jefferson died within hours of each other on the Fourth of July in 1826.",
	"Abraham Lincoln's dog Fido was the first 'First Dog' to be photographed.",
	"President Calvin Coolidge owned two lion cubs: Tax Reduction and Budget Bureau.",
	"President Rutherford B. Hayes' cat Siam was the first Siamese cat in the U.S.",
	"President John Quincy Adams' pet alligator lived in a White House bathroom.",
	"First Lady Abigail Adams famously wrote, 'If you love me...you must love my dog.'",
	"John Adams' pets Satan and Juno were the first dogs to live in the White House.",
	"Calvin Coolidge walked pet raccoon Rebecca on a leash around the White House.",
	"More presidents have had pet birds than cats.",
	"Thomas Jefferson's pet mockingbird was trained to eat out of his mouth.",
	"Spotty Bush, an English Springer Spaniel, has been the only presidential pet to live at the White House during two different administrations.",
	"Andrew Jackson was the first president to ride on a railroad train.",
	"Pat Nixon was the first First Lady to wear pants in public.",
	"First Lady Martha Washington was the first American woman to be honored on a U.S. postage stamp.",
	"When snakes are born with two heads, they fight each other for food.",
	"Venus is the only planet to rotate clockwise.",
	"Tennessee ties with Missouri as the most neighborly state, bordered by 8 states.",
	"The cotton candy machine was invented in 1897, by a dentist.",
	"You can’t hum while plugging your nose.",
	"Elephants are afraid of bees.",
	"They used to offer goat carriage rides in Central Park.",
	"Chimps can develop their own fashion trends.",
	"Monday is the only day of the week with an anagram: dynamo.",
	"The only Michelangelo painting in the Western Hemisphere is on display in Fort Worth, TX.",
	"Humans are 1-2 centimeters taller in the morning than at night.",
	"Baby giraffes fall up to 6 feet to the ground when they are born.",
	"It takes around 200 muscles to take a step.",
	"The flamingo can only eat when its head is upside down.",
	"A bald eagle nest can weigh up to two tons.",
	"Worrying squirrels is not tolerated in Missouri.",
	"Wombat droppings are cube-shaped.",
	"Adult humans are the only mammal that can't breathe and swallow at the same time.",
	"Hens do not need a rooster to lay an egg.",
	"There are more nerve connections or 'synapses' in your brain than there are stars in our galaxy.",
	"There are more English words beginning with the letter 'S' than any other letter.",
	"There are more fake than real flamingos.",
	"The word “bride” comes from an old Proto-Germanic word meaning “to cook.”",
	"The word utopia – an ideal place – ironically comes from a Greek word meaning “no place.”",
	"Los Angeles was originally founded as El Pueblo de la Reina de Los Angeles.",
	"The woolly mammoth still roamed the earth while the pyramids were being built.",
	"Nine-banded armadillos almost always give birth to four identical quadruplets.",
	"Jellyfish don’t have brains.",
	"Jellyfish can clone themselves.",
	"The koala is the longest-sleeping animal, sleeping an average of 22 hours per day.",
	"Walruses are true party animals; they can go without sleep for 84 hours.",
	"The city of Chicago was raised by over a foot during the 1850s and ’60s without disrupting daily life.",
	"Red kangaroos can hop up to 44 mph.",
	"Arkansas has the only active diamond mine in the United States.",
	"Robert Heft, who designed the current U.S. flag in a high school project, received a B- because it 'lacked originality.'",
	"The first 18-hole golf course in America was built on a sheep farm in 1892.",
	"Most newborns will lose all the hair they are born with in the first six months of life.",
	"Ripening bananas glow an intense blue under black light.",
	"Coconut water was used as an IV drip in WWII when saline solution was in short supply.",
	"Mercury and Venus are the only planets in our solar system with no moon.",
	"Peanuts are not actually nuts but legumes.",
	"The Oscar statuette is brittanium plated with 24K gold.",
	"The only thing that can scratch a diamond is a diamond.",
	"There is a star that is a diamond of ten billion trillion trillion carats.",
	"One ounce of gold can be stretched into a thin wire measuring 50 miles.",
	"A $100,000 bill exists, but was only used by Federal Reserve Banks.",
	"10 million bricks were used to build the Empire State Building.",
	"One quarter of all the body’s bones are in the feet.",
	"Lake Havasu City, AZ, has been recorded as the hottest city in the U.S. with average summer temperatures of 94.6.",
	"Early sunscreens included ingredients like rice bran oil, iron, clay, and tar.",
	"One of the first sunscreens was sold in the 1910s under the name Zeozon.",
	"In the U.S., there is an official rock, paper, scissors league.",
	"The largest bill ever issued by the U.S. was a $100,000 bill in 1934.",
	"Kickball is referred to as “soccer-baseball” in some parts of Canada.",
	"Less than 1% of Sweden’s household waste ends up in a dump.",
	"Duck Duck Goose is called Duck Duck Grey Duck in Minnesota.",
	"There are more tigers owned by Americans than in the wild worldwide.",
	"Hawaiian pizza was actually created in Canada.",
	"A city in Greece struggles to build subway systems because they keep digging up ancient ruins.",
	"Elvis was a natural blonde.",
	"On Venus, it snows metal.",
	"Eating 600 bananas is the equivalent of one chest X-ray in terms of radiation.",
	"The potato became the first vegetable to be grown in space.",
	"The average dog can understand over 150 words.",
	"At one time, serving ice cream on cherry pie in Kansas was prohibited.",
	"Blueberries are one of the only natural foods that are truly blue in color.",
	"Blueberries are also called “star berries.”",
	"There are more varieties of blueberries than states in the U.S.",
	"Typically, blueberries become ripe after 2-5 weeks on a bush.",
	"Love blueberries. Celebrate them all year round, but especially in July, National Blueberry Month.",
	"While blueberries grow in clusters on their bush, the individual blueberries ripen at different times.",
	"The first commercial batch of blueberries came from Whitesbog, New Jersey, in 1916.",
	"The perfect blueberry should be “dusty” in color.",
	"Maine produces more wild blueberries than anywhere else in the world.",
	"75% of the U.S.’s tart cherries come from Michigan.",
	"Traverse, MI, considers itself the Cherry Capital of the World.",
	"Once cherries have been picked, they don’t ripen.",
	"Make sure to eat a chocolate-covered cherry on January 3; it’s National Chocolate-Covered Cherry Day.",
	"On average, how many cherries are in a pound? 44.",
	"The word “cherry” comes from the Turkish town of Cerasus.",
	"A cherry pie is made of about 250 cherries.",
	"Eau Claire, Michigan, is known as “The Cherry Pit Spitting Capital of the World.”",
	"The National Anthem of Greece has 158 verses.",
	"North Korea and Finland are technically separated by only one country.",
	"Australia’s first police force was made up of the most well-behaved convicts.",
	"Emergency phone number in Europe is 112.",
	"Canada's postal code for Santa Claus at the North Pole is H0H 0H0.",
	"Russia has a larger surface area than Pluto.",
	"In New Zealand, it is illegal to name your twin babies 'Fish' and 'Chips.'",
	"Chocolate bars and blue denim both originated in Guatemala.",
	"In New Zealand, parents have to run baby names by the government for approval.",
	"When a child loses their tooth in Greece, they throw it on the roof as a good luck wish that their adult teeth will be strong.",
	"Australia is the only nation to govern an entire continent and its outlying islands.",
	"No one in Greece can choose not to vote; voting is required by law for every citizen who is 18 or older.",
	"Australia has 10,685 beaches; you could visit a new beach every day for more than 29 years.",
	"China is large enough to cover about five separate time zones, but only has one national time zone since the Chinese Civil War in 1949.",
	"There is a language in Botswana that consists of mainly five types of clicks.",
	"An African elephant can turn the pages of a book with its trunk.",
	"Ancient Egyptians slept on head rests made of wood, ivory, or stone.",
	"A traffic jam once lasted for 11 days in Beijing, China.",
	"Alaska is the only state that can be typed on one row of keys.",
	"The blue in the Sistine Chapel is made of ground lapis lazuli gems and oils.",
	"'The Bridge of Eggs' built in Lima, Peru, was made of mortar that was mixed with egg whites.",
	"In South Korea, you are one year old at birth.",
	"The Great Wall of China is 13,170.7 miles long, over five times the distance from LA to NYC.",
	"The horizontal line between two numbers in a fraction is called a vinculum.",
	"The metal ring on the end of a pencil is called a ferrule.",
	"You cannot taste food until mixed with saliva.",
	"There is an uninhabited island in the Bahamas known as Pig Beach, which is populated entirely by swimming pigs.",
	"Lake Hillier, in Western Australia, is colored a bright pink.",
	"Spiked dog collars were invented by the Ancient Greeks, who used them on their sheepdogs to protect their necks from wolves.",
	"'Buffalo buffalo Buffalo buffalo buffalo buffalo Buffalo buffalo.' is a grammatically correct sentence.",
	"On Jupiter and Saturn, it rains diamonds.",
	"Nowhere in the Humpty Dumpty nursery rhyme does it say that Humpty Dumpty is an egg.",
	"Located on the Detroit River, the J.W. Wescott II is the only floating post office in the U.S. and has its own ZIP Code: 48222.",
	"Antarctica is the largest desert in the world.",
	"Tomatoes have more genes than humans.",
	"In Texas, it is legal to kill Bigfoot if you ever find it.",
	"Elephants can smell water up to 3 miles away.",
	"A snail can grow back a new eye if it loses one.",
	"You can tell a turtle’s gender by the noise it makes. Males grunt and females hiss.",
	"French poodles actually originated in Germany.",
	"Marine mammals swim by moving their tails up and down, while fish swim by moving their tails left and right.",
	"“Knocker uppers” were professionals paid to shoot peas at windows. They were replaced by alarm clocks.",
	"An average cumulus cloud weighs more than 70 adult T. rexes.",
	"Clicking your computer mouse 1,400 times burns one calorie.",
	"'Guy' was once an insult for anyone dressed in poor clothes, originating from the burning of effigies of the infamous British rebel, Guy Fawkes.",
	"The national animal of Scotland is the unicorn.",
	"The tea bag was created by accident in 1908 by Thomas Sullivan of New York.",
	"The male ostrich can roar just like a lion.",
	"A group of frogs is called an army.",
	"Corn always has an even number of rows on each ear.",
	"You are always looking at your nose; your brain just chooses to ignore it.",
	"There is a single mega-colony of ants that spans three continents, covering much of Europe, the west coast of the U.S., and the west coast of Japan.",
	"The world's largest mountain range is under the sea.",
	"The Anglo-Zanzibar war of 1896 is the shortest war on record, lasting an exhausting 38 minutes.",
	"Below the Kalahari Desert lies the world's largest underground lake.",
	"Oregon and Mexico once shared a border.",
	"Bluetooth technology was named after a 10th century Scandinavian king.",
	"A nun held one of the first PhDs in computer science.",
	"For 67 years, Nintendo only produced playing cards.",
	"The ancient Chinese carried Pekingese puppies in the sleeves of their robes.",
	"A tarantula can survive for more than two years without food.",
	"Ethiopia follows a calendar that is seven years behind the rest of the world.",
	"In Denmark, citizens have to select baby names from a list of 7,000 government-approved names.",
	"Every tweet Americans send is archived by the Library of Congress.",
	"A neuron star is as dense as stuffing 50 million elephants into a thimble.",
	"More energy from the sun hits Earth every hour than the planet uses in a year.",
	"An earthquake in 1812 caused the Mississippi River to flow backward.",
	"In 2014, the Department of Veterans Affairs was still paying a Civil War pension.",
	"In Webster's Dictionary, the longest words without repeating letters are “uncopyrightable” and “dermatoglyphics.”",
	"“Unprosperousness” is the longest word in which no letter occurs only once.",
	"“Typewriter” and “perpetuity” are the longest words that can be typed on a single line of a QWERTY keyboard.",
	"There have been three Olympic games held in countries that no longer exist.",
	"Golf is the only sport to be played on the moon.",
	"The word 'checkmate' comes from the Persian phrase meaning 'the king is dead.'",
	"The brain is the only organ in the human body without pain receptors.",
	"There is a volcano on Mars the size of Arizona.",
	"The blue whale can produce the loudest sound of any animal. At 188 decibels, the noise can be detected over 800 kilometers away.",
	"Dogs’ sense of hearing is more than ten times more acute than a human’s.",
	"A housefly hums in the key of F.",
	"Venus is the only planet in the solar system where the sun rises in the west.",
	"The state animal of Tennessee is a raccoon.",
	"If you were to stretch out a Slinky until it’s flat, it would measure 87 feet long.",
	"It's illegal in many countries to perform surgery on an octopus without anesthesia because of its intelligence.",
	"There are more trees on Earth than stars in the galaxy.",
	"Human thigh bones are stronger than concrete.",
	"Fires spread faster uphill than downhill.",
	"The Florida Everglades is the only place in the world where both alligators and crocodiles live together.",
	"Newborns can't cry actual tears. This normally occurs between 3 weeks and 3 months of life.",
	"If you could drive your car upward, you would be in space in less than an hour.",
	"The sun is actually white, but the Earth’s atmosphere makes it appear yellow.",
	"The Earth rotates at a speed of 1,040 MPH.",
	"Even when a snake has its eyes closed, it can still see through its eyelids.",
	"The word 'aegilops' is the longest word in the English language to have all of its letters in alphabetical order.",
	"Gorillas burp when they are happy.",
	"Because of metal prices, since 2006 the U.S. Mint has had to spend more to make a penny than they are worth.",
	"'Never odd or even' spelled backward is still 'Never odd or even.'",
	"In Alabama, it's illegal to carry an ice cream cone in your back pocket at any time.",
	"Alaska is the most northern, western, and eastern U.S. state.",
	"In France, it's illegal for employers to send emails after work hours.",
	"A group of raccoons is called a gaze.",
	"Pteronophobia is the fear of being tickled by feathers.",
	"Cherophobia is the fear of happiness.",
	"The vertical distance between the Earth's highest and lowest points is about 12 miles.",
	"A flock of crows is known as a murder.",
	"Dr. Seuss wrote 'Green Eggs and Ham' to win a bet with his publisher who thought he could not complete a book with only 50 words.",
	"Over 80% of the land in Nevada is owned by the U.S. government.",
	"There are more people on Facebook today than there were on the Earth 200 years ago.",
	"Mangoes have noses.",
	"Mangoes can get sunburned.",
	"Before 1859, baseball umpires sat behind home plate in rocking chairs.",
	"The shortest professional baseball player was 3 feet, 7 inches tall.",
	"The average life span of an MLB baseball is five to seven pitches.",
	"The most valuable baseball card ever is worth about $2.8 million.",
	"The paisley pattern is based on the mango.",
	"In India, mango leaves are used to celebrate the birth of a boy.",
	"A flipped coin is more likely to land on the side it started on.",
	"When sprinting, professional cyclists produce enough power to power a home.",
	"Mosquitoes prefer to bite people with Type O blood.",
	"During a typical MLB season, approximately 160,000 baseballs are used.",
	"The Bible is the world's most shoplifted book.",
	"The British pound is the world's oldest currency still in use.",
	"The Great Lakes have more than 30,000 islands.",
	"Mountain lions can whistle.",
	"While rabbits have near-perfect 360-degree panoramic vision, their most critical blind spot is directly in front of their nose.",
	"When a koala is born, it is about the size of a jelly bean.",
	"Toe wrestling is a competitive sport.",
	"There have been 85 recorded instances of a pitcher striking out four batters in one inning.",
	"3.7 million bags of ballpark peanuts are eaten every year at ballparks.",
	"Shakespeare created the name Jessica for his play 'The Merchant of Venice.'",
	"Tooth enamel is the hardest substance in the human body.",
	"The mummy of Pharaoh Ramesses II has a passport.",
	"It is physically impossible for a pig to look at the sky.",
	"There are more stars in the universe than grains of sand on earth.",
	"A caterpillar has more muscles than a human.",
	"A shrimp's heart is in its head.",
	"A human being could swim through the blood vessels of a blue whale.",
	"Light could travel around the earth nearly 7.5 times in one second.",
	"A single lightning bolt contains enough energy to cook 100,000 pieces of toast.",
	"About one in every 2,000 babies is born with teeth.",
	"Water can boil and freeze at the same time.",
	"Less than 5% of the population needs just 4-5 hours of sleep.",
	"Peanut butter can be converted into diamonds.",
	"Astronauts can't burp in space.",
	"An Immaculate Inning is when a pitcher strikes out three batters with only nine pitches.",
	"Earth is the only planet not named after a Greek or Roman god.",
	"Yawns are contagious to dogs as well as humans.",
	"In the 1960s, the U.S. government tried to turn a cat into a spy.",
	"Movie trailers used to come on at the end of movies, but no one stuck around to watch them.",
	"MLB umpires often wear black underwear, in case they split their pants.",
	"It is possible to record four outs in one-half inning of baseball.",
	"There are nine different ways to reach first base.",
	"During World War II, the U.S. military designed a grenade to be the size and weight of a baseball, since 'any young American man should be able to properly throw it.'",
	"Philadelphia zookeeper Jim Murray sent baseball scores to telegraph offices by carrier pigeon every half inning in 1883.",
	"From 1845 through 1867, home base was circular, made of iron, painted or enameled white, and 12 inches in diameter.",
	"President Bill Clinton's first presidential pitch (on April 4, 1993) was the first ever from the pitcher's mound to the catcher's mitt.",
	"Thunder is actually the sound caused by lightning.",
	"Australia is wider than the moon.",
	"85% of people only breathe out of one nostril at a time.",
	"An albatross can sleep while it flies.",
	"In a room of 23 people, there is a 50% chance that two people have the same birthday.",
	"Bubble wrap was originally invented as a wallpaper in 1957.",
	"There is a species of jellyfish that is immortal.",
	"Of the 193 members of the United Nations, Britain has invaded 171 of them.",
	"The Apollo 11 guidance computer was no more powerful than today's pocket calculator.",
	"“Sphenopalatine ganglioneuralgia” is the technical name for brain freeze.",
	"Earth is actually located inside the sun's atmosphere.",
	"The spiral shapes of sunflowers follow the Fibonacci sequence.",
	"If you drilled a hole through the earth, it would take 42 minutes to fall through it.",
	"The planet 55 Cancri e is made of diamonds and would be worth $26.9 nonillion.",
	"France used the guillotine as recently as 1977.",
	"Sloths move so slow that algae can grow on them.",
	"Zero is the only number that cannot be represented by Roman numerals.",
	"Michelangelo hated painting and wrote a poem about it.",
	"The dwarf lantern shark grows to be no bigger than a human hand.",
	"'Tools of ignorance' is a nickname for the equipment worn by catchers.",
	"More than 100 baseballs are used during a typical MLB game.",
	"Pitchers were prohibited from delivering the ball overhand for much of the 19th century.",
	"Walks were scored as hits during the 1887 season.",
	"A regulation baseball has 108 stitches.",
	"A 'can of corn' is a routine fly ball hit to an outfielder.",
	"Baseball is played in more than 100 countries.",
	"“Take Me Out to the Ballgame” was written in 1908 by Jack Norworth and Albert Von Tilzer, both of whom had never been to a baseball game.",
	"A baseball pitcher’s curveball can break up to 17 inches.",
	"MLB baseballs are rubbed in Lena Blackburne Baseball Rubbing Mud, a unique mud found only near Palmyra, New Jersey.",
	"The Metropolitan Museum of Art has over 30,000 baseball cards as part of the Jefferson R. Burdick collection.",
	"William Howard Taft, the 27th president of the U.S., began the tradition of throwing out the ceremonial first pitch in 1910.",
	"MLB National League (1876) is the oldest professional sports league that is still in existence.",
	"The first modern-day World Series game was played in 1903.",
	"The Mendoza Line is a .200 batting average.",
	"There are 13 different pitches a pitcher can throw in baseball.",
	"The first MLB All-Star Game was played in 1933.",
	"A player was once ejected from an MLB game for sleeping during the game.",
	"Baseball hits that bounced over the fence were considered home runs until the 1930s.",
	"The most home runs ever recorded in an MLB season is 73.",
	"The highest batting average ever recorded in an MLB season is .440.",
	"MLB has not had a lefty play catcher since 1989.",
	"The longest MLB game went 26 innings."
}

local nonsenseWords = {
	"lol", "i", "am", "drinking", "this", "tower", "and", "you", "should", "not", 
	"care", "about", "the", "banana", "why", "is", "sky", "green", "when", "it", 
	"rains", "fast", "computer", "running", "on", "toast", "mouse", "eats", "cheese", 
	"pizza", "dancing", "with", "chairs", "because", "nobody", "knows", "how", "to",
	"jump", "over", "the", "moon", "but", "cats", "fly", "at", "midnight", "without", 
	"shoes", "please", "call", "me", "when", "you", "see", "purple", "elephants"
}

local function getRandomFunFact()
	return funFacts[math.random(1, #funFacts)]
end

local function randomNonsenseSentence()
	local length = math.random(5, 12)
	local words = {}
	for i = 1, length do
		table.insert(words, nonsenseWords[math.random(1, #nonsenseWords)])
	end
	return table.concat(words, " ")
end

local function enableBodyGyro()
	if bodyGyro.Parent ~= HRP then
		bodyGyro.Parent = HRP
	end
end

local function disableBodyGyro()
	if bodyGyro.Parent ~= ReplicatedStorage then
		bodyGyro.Parent = ReplicatedStorage
	end
end

local function sayMessage(text)
	local channel = TextChatService.TextChannels:FindFirstChild("RBXGeneral")
	if channel then
		channel:SendAsync(text)
	end
end

local function getTool()
	-- Check Character first, then Backpack
	for _, tool in ipairs(CHARACTER:GetChildren()) do
		if tool:IsA("Tool") then
			return tool
		end
	end
	for _, tool in ipairs(LOCAL_PLAYER.Backpack:GetChildren()) do
		if tool:IsA("Tool") then
			return tool
		end
	end
	return nil
end

local function computePath(targetPos)
	path = PathfindingService:CreatePath()
	path:ComputeAsync(HRP.Position, targetPos)
	return path
end

local function followPath()
	if not path or path.Status ~= Enum.PathStatus.Success then return end
	for _, waypoint in ipairs(path:GetWaypoints()) do
		HUMANOID:MoveTo(waypoint.Position)
		local reached = false
		local conn
		conn = HUMANOID.MoveToFinished:Connect(function()
			reached = true
		end)
		while not reached and (chasing or following) do
			RunService.Heartbeat:Wait()
			if currentTarget and (currentTarget.Character.HumanoidRootPart.Position - lastTargetPos).Magnitude > 10 then
				conn:Disconnect()
				return "recompute"
			end
		end
		conn:Disconnect()
	end
end

local function faceTarget(distance)
	if currentTarget and currentTarget.Character and currentTarget.Character:FindFirstChild("HumanoidRootPart") then
		local dir = (currentTarget.Character.HumanoidRootPart.Position - HRP.Position).Unit
		local yawOnly = CFrame.new(Vector3.zero, Vector3.new(dir.X, 0, dir.Z))

		if distance and distance <= 14 and chasing then
			local wiggleSpeed = 55
			local wiggleAmount = math.clamp((14 - distance) / 14, 0, 1) * 0.6
			local t = tick() * wiggleSpeed
			local offsetYaw = math.sin(t) * wiggleAmount
			bodyGyro.CFrame = yawOnly * CFrame.Angles(0, offsetYaw, 0)
		else
			bodyGyro.CFrame = yawOnly
		end
	end
end

local function wiggleMove(distance)
	local speed = 55
	local intensity = math.clamp((14 - distance) / 14, 0, 1) * 25
	local t = tick() * speed
	HUMANOID:Move(Vector3.new(math.sin(t) * intensity, 0, 0))
end

local function scribbleMove()
	local t = tick()
	HUMANOID:Move(Vector3.new(math.sin(t * 25), 0, math.cos(t * 30)))
end

local function strafeSequence()
	strafeActive = true
	local jump = math.random(1, 2) == 1
	local repeats = math.random(1, 2)
	for i = 1, repeats do
		local x = math.random(-1, 1)
		local z = math.random(-1, 1)
		local vec = Vector3.new(x, 0, z)
		if vec.Magnitude == 0 then vec = Vector3.new(1, 0, 0) end
		vec = vec.Unit
		HUMANOID:Move(vec)
		if jump then
			HUMANOID.Jump = true
			wait(0.25)
			HUMANOID.Jump = false
		end
		wait(0.3)
	end
	strafeActive = false
end

local function walkToCommander()
	if currentCommander and currentCommander.Character and currentCommander.Character:FindFirstChild("HumanoidRootPart") then
		local pos = currentCommander.Character.HumanoidRootPart.Position
		HUMANOID:MoveTo(pos + Vector3.new(0, 0, 10))
	end
end

local function sortTargetsByDistance(t)
	table.sort(t, function(a, b)
		local aHRP = a.Character and a.Character:FindFirstChild("HumanoidRootPart")
		local bHRP = b.Character and b.Character:FindFirstChild("HumanoidRootPart")
		if aHRP and bHRP then
			return (aHRP.Position - HRP.Position).Magnitude < (bHRP.Position - HRP.Position).Magnitude
		end
		return false
	end)
end

local function getPlayerByPartialName(name)
	name = name:lower()
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LOCAL_PLAYER and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
			if player.Name:lower():find(name) then
				return player
			end
		end
	end
end

local function parseTargetsList(message)
	message = message:lower()
	if message == "others" then
		local r = {}
		for _, p in ipairs(Players:GetPlayers()) do
			if p ~= LOCAL_PLAYER and not WHITELIST[p.Name] then
				table.insert(r, p)
			end
		end
		return r

	elseif message == "all" or message == "everyone" then
		local r = {}
		for _, p in ipairs(Players:GetPlayers()) do
			if p ~= LOCAL_PLAYER then
				table.insert(r, p)
			end
		end
		return r

	elseif message:find(" and ") then
		local r = {}
		for name in string.gmatch(message, "[^%s]+") do
			if name ~= "and" then
				local found = getPlayerByPartialName(name)
				if found then
					table.insert(r, found)
				end
			end
		end
		return r

	else
		local single = getPlayerByPartialName(message)
		if single then return { single } end
	end

	return {}
end

local function killPlayer(targetPlayer)
	local tool = getTool()
	if not tool then
		sayMessage("tool required to kill " .. targetPlayer.Name)
		return
	end

	tool.Parent = CHARACTER
	enableBodyGyro()

	currentTarget = targetPlayer
	chasing = true
	local startTime = tick()

	while chasing and currentTarget and currentTarget.Character and currentTarget.Character:FindFirstChild("HumanoidRootPart") do
		local hrp = currentTarget.Character.HumanoidRootPart
		local distance = (HRP.Position - hrp.Position).Magnitude

		faceTarget(distance)

		if distance <= 35 then
			pcall(function()
				tool:Activate()
			end)
		end

		if distance >= 43.5 and math.random(1, 5) == 1 and not strafeActive then
			task.spawn(strafeSequence)
		end

		if distance > 14 then
			lastTargetPos = hrp.Position
			computePath(lastTargetPos)
			local result = followPath()
			if result == "recompute" then continue end
		else
			if distance <= 14 then
				wiggleMove(distance)
			elseif distance <= 5 then
				scribbleMove()
			else
				HUMANOID:Move(Vector3.new(0, 0, 0))
			end
		end

		if currentTarget.Character:FindFirstChildOfClass("Humanoid").Health <= 0 then
			sayMessage("Successfully killed " .. currentTarget.Name)
			chasing = false
			break
		end

		if tick() - startTime >= 60 then
			sayMessage("Failed to kill " .. currentTarget.Name)
			chasing = false
			break
		end

		RunService.Heartbeat:Wait()
	end

	HUMANOID:UnequipTools()
	disableBodyGyro()
	wait(0.5)
	walkToCommander()
	currentTarget = nil
end

local function killMultiplePlayers(targets)
	sortTargetsByDistance(targets)
	for _, player in ipairs(targets) do
		if not chasing then break end
		killPlayer(player)
	end
end

local function followPlayer(targetPlayer)
	currentTarget = targetPlayer
	following = true

	while following and currentTarget and currentTarget.Character and currentTarget.Character:FindFirstChild("HumanoidRootPart") do
		local hrp = currentTarget.Character.HumanoidRootPart
		local distance = (HRP.Position - hrp.Position).Magnitude

		if distance > 5 then
			lastTargetPos = hrp.Position
			computePath(lastTargetPos)
			local result = followPath()
			if result == "recompute" then continue end
		else
			HUMANOID:Move(Vector3.new(0,0,0))
		end

		RunService.Heartbeat:Wait()
	end

	currentTarget = nil
end

local function followMultiplePlayers(targets)
	sortTargetsByDistance(targets)
	for _, player in ipairs(targets) do
		if not following then break end
		followPlayer(player)
	end
end

local trollEmotes = {
	"/e dance", "/e laugh", "/e point", "/e wave", "/e cheer"
}

local function trollBehavior()
	trolling = true
	while trolling do
		local x = math.random(-100, 100)
		local z = math.random(-100, 100)
		HUMANOID:MoveTo(HRP.Position + Vector3.new(x, 0, z))
		sayMessage(trollEmotes[math.random(1, #trollEmotes)])
		wait(math.random(5, 10))
	end
end

local function nonsenseBehavior()
	nonsenseMode = true
	task.spawn(trollBehavior)
	while nonsenseMode do
		sayMessage(randomNonsenseSentence())
		wait(math.random(4, 7))
	end
end

local function onCopyChatted(player, msg)
	if copyingPlayer and player == copyingPlayer then
		sayMessage(msg)
	end
end

local function onChatted(sender, message)
	if not WHITELIST[sender.Name] then return end
	if not message:lower():sub(1, 4) == "ai: " then return end

	currentCommander = sender
	message = message:sub(5):lower()

	if message:sub(1, 5) == "kill " then
		local targets = parseTargetsList(message:sub(6))
		if #targets > 0 then
			following = false
			trolling = false
			nonsenseMode = false
			copyingPlayer = nil
			chasing = true
			task.spawn(killMultiplePlayers, targets)
		end

	elseif message:sub(1, 7) == "follow " then
		local targets = parseTargetsList(message:sub(8))
		if #targets > 0 then
			chasing = false
			trolling = false
			nonsenseMode = false
			copyingPlayer = nil
			following = true
			task.spawn(followMultiplePlayers, targets)
		end

	elseif message == "stop" or message == "freeze" or message == "abort" then
		chasing = false
		following = false
		trolling = false
		nonsenseMode = false
		copyingPlayer = nil
		disableBodyGyro()
		sayMessage("Stopped.")

	elseif message == "troll" then
		chasing = false
		following = false
		nonsenseMode = false
		copyingPlayer = nil
		trolling = true
		task.spawn(trollBehavior)

	elseif message == "nonsense" then
		chasing = false
		following = false
		trolling = false
		copyingPlayer = nil
		nonsenseMode = true
		task.spawn(nonsenseBehavior)

	elseif message:sub(1, 5) == "copy " then
		local pName = message:sub(6)
		local p = getPlayerByPartialName(pName)
		if p then
			chasing = false
			following = false
			trolling = false
			nonsenseMode = false
			copyingPlayer = p
			p.Chatted:Connect(onCopyChatted)
			sayMessage("Copying " .. p.Name)
		end

	elseif message == "fact" or message == "fun fact" or message == "fax" then
		sayMessage(getRandomFunFact())
	end
end

Players.PlayerAdded:Connect(function(p)
	if WHITELIST[p.Name] then
		p.Chatted:Connect(function(msg)
			onChatted(p, msg)
		end)
	end
end)

for _, p in ipairs(Players:GetPlayers()) do
	if WHITELIST[p.Name] then
		p.Chatted:Connect(function(msg)
			onChatted(p, msg)
		end)
	end
end

local Players = game:GetService("Players")
local PathfindingService = game:GetService("PathfindingService")
local RunService = game:GetService("RunService")
local TextChatService = game:GetService("TextChatService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LOCAL_PLAYER = Players.LocalPlayer
local CHARACTER = LOCAL_PLAYER.Character or LOCAL_PLAYER.CharacterAdded:Wait()
local HUMANOID = CHARACTER:WaitForChild("Humanoid")
local HRP = CHARACTER:WaitForChild("HumanoidRootPart")

local WHITELIST = { ["PlayerEater9"] = true, ["RealPerson_0010"] = true, ["RealPerson_2005"] = true, ["MEUGLYTHEPERSON"] = true }

local currentTarget = nil
local currentCommander = nil
local chasing = false
local following = false
local trolling = false
local nonsenseMode = false
local copyingPlayer = nil
local strafeActive = false
local path
local lastTargetPos

local bodyGyro = Instance.new("BodyGyro")
bodyGyro.Name = "AimGyro"
bodyGyro.MaxTorque = Vector3.new(0, math.huge, 0)
bodyGyro.P = 100000
bodyGyro.D = 1000
bodyGyro.CFrame = HRP.CFrame
bodyGyro.Parent = ReplicatedStorage

local funFacts = {
	"Octopuses have three hearts.",
	"Bananas are berries but strawberries are not.",
	"The Eiffel Tower can be 15 cm taller during the summer.",
	"The sun can give you vitamin D.",
	"Sharks have been around longer than trees.",
	"Honey never spoils.",
	"A group of flamingos is called a flamboyance.",
	"Taking breaks every now and then can boost your immune system.",
	"The tiny pocket in jeans was designed to store pocket watches.",
	"Your heart beats an average of 100,000 times each day.",
	"The longest English word is 189,819 letters long.",
	"The Eiffel Tower was originally made for Barcelona.",
	"The real name for a hashtag is an octothorpe.",
	"The world’s longest concert lasted 453 hours.",
	"A fear of long words is called Hippopotomonstrosesquippedaliophobia (Whoever came up with this is a monster).",
	"Karate originated in India.",
	"The infinity sign is called a lemniscate.",
	"Children grow faster during springtime.",
	"It takes an interaction of 72 muscles to produce human speech.",
	"Sailors once thought wearing gold earrings improved eyesight.",
	"Our eyes are always the same size from birth, but our nose and ears never stop growing.",
	"Your skull is made up of 29 different bones.",
	"Every hour more than one billion cells in the body must be replaced.",
	"Women's hearts typically beat faster than men's hearts.",
	"Adults laugh only about 15 to 100 times a day, while six-year-olds laugh an average of 300 times a day.",
	"Children have more taste buds than adults.",
	"Right handed people tend to chew food on the right side and lefties chew on the left.",
	"A cucumber consists of 96% water.",
	"Vanilla is used to make chocolate.",
	"One lump of sugar is equivalent to three feet of sugar cane.",
	"A lemon contains more sugar than a strawberry.",
	"Until the nineteenth century, solid blocks of tea were used as money in Siberia.",
	"Wild camels once roamed Arizona's deserts.",
	"New York was the first state to require cars to have license plates.",
	"Miami installed the first ATM for rollerbladers.",
	"Hawaii has its own time zone.",
	"Oregon has more ghost towns than any other US state.",
	"Cleveland, OH is home to the first electric traffic lights.",
	"South Carolina is home to the first tea farm in the U.S.",
	"The term rookies comes from a Civil War term, reckie, which was short for recruit.",
	"Taft was the heaviest U.S. President at 329lbs; Madison was the smallest at 100lbs.",
	"Harry Truman was the last U.S. President to not have a college degree.",
	"Abraham Lincoln was the tallest U.S. President at 6'4', while James Madison was the shortest at 5'4'.",
	"Franklin Roosevelt was related to 5 U.S. Presidents by blood and 6 by marriage.",
	"Thomas Jefferson invented the coat hanger.",
	"Theodore Roosevelt had a pet bear while in office.",
	"President Warren G. Harding once lost white house china in a poker game.",
	"Ulysses Simpson Grant was fined $20.00 for speeding on his horse.",
	"President William Taft weighed over 300 lbs and once got stuck in the white house bathtub.",
	"President William McKinley had a pet parrot that he named “Washington Post.”",
	"Harry S. Truman's middle name is S.",
	"The youngest U.S. president to be in office was Theodore Roosevelt at age 42.",
	"Most Koala bears can sleep up to 22 hours a day.",
	"In 1859, 24 rabbits were released in Australia. Within 6 years, the population grew to 2 million.",
	"Butterflies can taste with their hind feet.",
	"A strand from the web of a golden spider is as strong as a steel wire of the same size.",
	"The bumblebee bat is one of the smallest mammals on Earth. It weighs less than a penny.",
	"The Valley of Square Trees in Panama is the only known place in the world where trees have rectangular trunks.",
	"The original Cinderella was Egyptian and wore fur slippers.",
	"The plastic things on the end of shoelaces are called aglets.",
	"Neckties were first worn in Croatia, which is why they were called cravats.",
	"Barbie's full name is Barbara Millicent Roberts.",
	"The first TV toy commercial aired in 1946 for Mr. Potato Head.",
	"If done perfectly, any Rubik's Cube combination can be solved in 17 turns.",
	"The side of a hammer is called a cheek.",
	"In Athens, Greece, a driver's license can be taken away by law if the driver is deemed either unbathed or poorly dressed.",
	"In Texas, it is illegal to graffiti someone's cow.",
	"Less than 3% of the water on Earth is fresh.",
	"A cubic mile of fog is made up of less than a gallon of water.",
	"The Saturn V moon rocket consumed 15 tons of fuel per second.",
	"A manned rocket can reach the moon in less time than it took a stagecoach to travel the length of England.",
	"At room temperature, the average air molecule travels at the speed of a rifle bullet.",
	"The lollipop was named after one of the most famous Racehorses in the early 1900s, Lolly Pop.",
	"Buzz Aldrin was one of the first men on the moon. His mother's maiden name was also Moon.",
	"Maine is the only state with a one-syllable name.",
	"The highest denomination issued by the U.S. was the 100,000 dollar bill.",
	"The White House was originally called the President's Palace. It became The White House in 1901.",
	"George Washington was the only unanimously elected President.",
	"John Adams was the only President to be defeated by his Vice President, Thomas Jefferson.",
	"New York City has over 800 miles of subway track.",
	"Manatees' eyes close in a circular motion, much like the aperture of a camera.",
	"Even though it is nearly twice as far away from the Sun as Mercury, Venus is by far the hottest planet.",
	"The nothingness of a black hole generates a sound in the key of B flat.",
	"Horses can't vomit.",
	"Babies are born with about 300 separate bones, but adults have 206.",
	"Newborn babies cannot cry tears for at least three weeks.",
	"A day on Venus lasts longer than a year on Venus.",
	"Squirrels lose more than half of the nuts they hide.",
	"The penny was the first U.S. coin to feature the likeness of an actual person.",
	"Forty percent of twins invent their own language.",
	"In South Korea, it is against the rules for a professional baseball player to wear cabbage leaves inside of his hat.",
	"Curly hair follicles are oval, while straight hair follicles are round.",
	"George Washington had false teeth made of gold, ivory, and lead - but never wood.",
	"Napoleon Bonaparte was actually not short. At 5' 7', he was average height for his time.",
	"The Inca built the largest and wealthiest empire in South America, but had no concept of money.",
	"It is against the law to use 'The Star Spangled Banner' as dance music in Massachusetts.",
	"Queen Cleopatra of Egypt was not actually Egyptian.",
	"Early football fields were painted with both horizontal and vertical lines, creating a pattern that resembled a gridiron.",
	"Two national capitals are named after U.S. presidents: Washington, D.C., and Monrovia, the capital of Liberia.",
	"The first spam message was transmitted over telegraph wires in 1864.",
	"A pearl can be dissolved by vinegar.",
	"Queen Isabella I of Spain, who funded Columbus' voyage across the ocean, claimed to have only bathed twice in her life.",
	"The longest attack of hiccups ever lasted 68 years.",
	"A bolt of lightning can reach temperatures hotter than 50,000 degrees Fahrenheit - five times hotter than the sun.",
	"At the deepest point in the ocean, the water pressure is equivalent to having about 50 jumbo jets piled on top of you.",
	"In only 7.6 billion years, the sun will reach its maximum size and will shine 3,000 times brighter.",
	"The state of Alabama once financed the construction of a bridge by holding a rooster auction.",
	"Federal law once allowed the government to quarantine people who came in contact with aliens.",
	"There are 21 'secret' highways that are part of the Interstate Highway System. They are not identified as such by road signs.",
	"The aphid insect is born pregnant.",
	"John Wilkes Booth's brother saved the life of Abraham Lincoln's son.",
	"It is illegal in the United Kingdom to handle salmon in suspicious circumstances.",
	"It is illegal to play annoying games in the street in the United Kingdom.",
	"Tennis was originally played with bare hands.",
	"-40 degrees Fahrenheit is the same temperatures as -40 degrees Celsius.",
	"U.S. President John Tyler had 15 children, the last of which was born when he was 70 years old.",
	"Dolphins are unable to smell.",
	"Charlie Chaplin failed to make the finals of a Charlie Chaplin look-alike contest.",
	"The name of the city of Portland, Oregon was decided by a coin toss. The name that lost was Boston.",
	"The letter J is the only letter in the alphabet that does not appear anywhere on the periodic table of the elements.",
	"'K' was chosen to stand for a strikeout in baseball because 'S' was being used to denote a sacrifice.",
	"A dimpled golf ball produces less drag and flies farther than a smooth golf ball.",
	"When grazing or resting, cows tend to align their bodies with the magnetic north and south poles.",
	"President Chester A. Arthur owned 80 pairs of pants, which he changed several times per day.",
	"Cows do not have upper front teeth.",
	"Between 1979 and 1999, the planet Neptune was farther from the Sun than Pluto. This won't happen again until 2227.",
	"When creating a mummy, Ancient Egyptians removed the brain by inserting a hook through the nostrils.",
	"All of the major candidates in the 1992, 1996, and 2008 U.S. presidential elections were left-handed.",
	"In Switzerland, it is illegal to own only one guinea pig because they are prone to loneliness.",
	"The first American gold rush happened in North Carolina, not California.",
	"To make one pound of honey, a honeybee must tap about two million flowers.",
	"Chicago is named after smelly garlic that once grew in the area.",
	"The Chicago river flows backwards; the flow reversal project was completed in 1900.",
	"The patent for the fire hydrant was destroyed in a fire.",
	"Powerful earthquakes can make the Earth spin faster.",
	"Baby bunnies are called kittens.",
	"A group of flamingos is called a flamboyance.",
	"Sea otters hold each other’s paws while sleeping so they don’t drift apart.",
	"Gentoo penguins propose to their life mates with a pebble.",
	"Male pups will intentionally let female pups “win” when they play-fight so they can get to know them better.",
	"A cat’s nose is ridged with a unique pattern, just like a human fingerprint.",
	"A group of porcupines is called a prickle.",
	"99% of our solar system's mass is the sun.",
	"More energy from the sun hits Earth every hour than the planet uses in a year.",
	"If two pieces of the same type of metal touch in outer space, they will bond together permanently.",
	"Just a sugar cube of neutron star matter would weigh about one hundred million tons on Earth.",
	"A soup can full of neutron star material would have more mass than the Moon.",
	"Ancient Chinese warriors would show off to their enemies before battle, by juggling.",
	"OMG was added to dictionaries in 2011, but its first known use was in 1917.",
	"In the state of Arizona, it is illegal for donkeys to sleep in bathtubs.",
	"The glue on Israeli postage stamps is certified kosher.",
	"Rats and mice are ticklish, and even laugh when tickled.",
	"Norway once knighted a penguin.",
	"The King of Hearts is the only king without a mustache.",
	"It is illegal to sing off-key in North Carolina.",
	"Forty is the only number whose letters are in alphabetical order.",
	"One is the only number with letters in reverse alphabetical order.",
	"Strawberries are grown in every state in the U.S. and every province in Canada.",
	"The phrase, “You’re a real peach” originated from the tradition of giving peaches to loved ones.",
	"At latitude 60° south, it is possible to sail clear around the world without touching land.",
	"Interstate 90 is the longest U.S. Interstate Highway with over 3,000 miles from Seattle, WA to Boston, MA.",
	"DFW Airport in Texas is larger than the island of Manhattan.",
	"Benjamin Franklin invented flippers.",
	"Miami installed the first ATM for inline skaters.",
	"Indonesia is made up of more than 17,000 islands.",
	"Giraffes have the same number of vertebrae as humans: 7.",
	"The official taxonomic classification for llamas is Llama glama.",
	"Remove all the space between its atoms and Earth would be the size of a baseball.",
	"The soil on Mars is rust color because it's full of rust.",
	"Sound travels up to 15 times faster through steel than air, at speeds up to 19,000 feet per second.",
	"Humans share 50% of their DNA with bananas.",
	"Maine is the closest U.S. state to Africa.",
	"An octopus has three hearts.",
	"Only 12 U.S. presidents have been elected to office for two terms and served those two terms.",
	"Franklin D. Roosevelt was elected to office for four terms prior to the 22nd Amendment.",
	"John F. Kennedy, at 43, was the youngest elected president, and Ronald Reagan, at 73, the oldest.",
	"James Buchanan is the only bachelor to be elected president.",
	"Eight presidents have died while in office.",
	"Bill Clinton was born William Jefferson Blythe III, but took his stepfather’s last name when his mother remarried.",
	"Prior to the 12th Amendment in 1804, the presidential candidate who received the second highest number of electoral votes was vice president.",
	"George Washington was a successful liquor distributor, making rye whiskey, apple brandy, and peach brandy in his Mount Vernon distillery.",
	"Thomas Jefferson and John Adams chipped off a piece of Shakespeare's chair as a souvenir when they visited his home in 1786.",
	"George Washington started losing his permanent teeth in his 20s and had only one natural tooth by the time he was president.",
	"George Washington had false teeth made from many different materials, including an elephant tusk and hippopotamus ivory.",
	"George Washington protected his beloved horses from losing their teeth by making sure they were brushed regularly.",
	"John Quincy Adams regularly skinny-dipped in the Potomac River.",
	"Calvin Coolidge was so shy, he was nicknamed “Silent Cal.”",
	"Calvin Coolidge loved to wear a cowboy hat and ride his mechanical horse.",
	"President Herbert Hoover invented “Hooverball” (a cross between volleyball and tennis using a medicine ball), which he played with his cabinet members.",
	"Andrew Jackson was involved in as many as 100 duels, many of which were fought to defend the honor of his wife, Rachel.",
	"Martin Van Buren's nickname was 'Old Kinderhook' because he was raised in Kinderhook, N.Y.",
	"James Buchanan bought slaves in Washington, D.C., and quietly freed them in Pennsylvania.",
	"Abraham Lincoln was only defeated once in about 300 wrestling matches, making it to the Wrestling Hall of Fame with honors as 'Outstanding American.'",
	"In his youth, President Andrew Johnson apprenticed as a tailor.",
	"Ulysses S. Grant smoked at least 20 cigars a day; citizens sent him at least 10,000 boxes in gratitude after winning the Battle of Shiloh.",
	"Not only was James Garfield ambidextrous, he could write Latin with one hand and Greek with the other at the same time.",
	"Benjamin Harrison was the first president to have electricity in the White House; however, he was so scared of getting electrocuted, he’d never touch the light switches himself.",
	"William McKinley almost always wore a red carnation on his lapel as a good-luck charm.",
	"Herbert Hoover's son had two pet alligators that were occasionally permitted to run loose throughout the White House.",
	"Jimmy Carter filed a report for a UFO sighting in 1973, calling it “the darndest thing I’ve ever seen.”",
	"Bill Clinton's face is so symmetrical that he ranked in facial symmetry alongside male models.",
	"In 1916, Jeannette Rankin of Montana became the first woman elected to Congress.",
	"Gerald Ford was the only president and vice president never to be elected to either office.",
	"Victoria Woodhull, in 1872, was the first woman to run for the U.S. presidency.",
	"James Monroe received every electoral vote but one in the 1820 election.",
	"There are only three requirements to become U.S. president: must be 35, a natural-born U.S. citizen, and have resided in the U.S. for at least 14 years.",
	"To cut groundskeeping costs during World War I, President Woodrow Wilson brought a flock of sheep to trim the White House grounds.",
	"Rutherford B. Hayes was the first president to use a phone, and his phone number was extremely easy to remember – simply “1.”",
	"Martin Van Buren was the first president born a U.S. citizen; all presidents before him were British.",
	"Andrew Jackson's pet parrot Poll was removed from his funeral for cursing.",
	"There has never been a U.S. president whose name started with the common letter S.",
	"Abraham Lincoln is the only U.S. president who was also a licensed bartender.",
	"Barack Obama is called the 44th president, but is actually the 43rd because Grover Cleveland is counted twice, as he was elected for two terms.",
	"Four times in U.S history has a presidential candidate won the popular vote but lost the election.",
	"President Herbert Hoover and his wife were fluent in Mandarin Chinese and would use it in the White House to speak privately to each other.",
	"November was chosen to be election month because it fell between harvest and brutal winter weather.",
	"Six of the last 12 U.S. presidents have been left-handed, far greater than the national average of lefties (10%).",
	"William Henry Harrison owned a pet goat while in office.",
	"John Adams had a horse named Cleopatra.",
	"James Madison had a pet parrot who outlived him and his wife.",
	"John Quincy Adams' wife raised silkworms.",
	"Martin Van Buren was given two tiger cubs while he was president.",
	"William Harrison had a billy goat at the White House.",
	"Franklin Pierce was gifted two small 'sleeve dogs' – he kept one and gave the other to Jefferson Davis.",
	"Abraham Lincoln's son had a pet turkey, which he gave a pardon so it wasn't killed and eaten.",
	"James Garfield had a dog appropriately named Veto.",
	"William Taft liked milk so much that he had cows graze on the White House lawn, Pauline being the last in history to graze there.",
	"Calvin Coolidge had a bulldog named Boston Beans, a terrier named Peter Pan, and a pet raccoon.",
	"John Kennedy had a pony named Macaroni.",
	"Lyndon Johnson had two beagles, named Him and Her, for which he was criticized for picking up by their ears.",
	"Jimmy Carter had a dog named Grits, a gift given to his daughter Amy.",
	"Bill Clinton had a cat named Socks, which was the first presidential pet to have its own website.",
	"Woodrow Wilson passed the Georgia Bar Exam despite not finishing law school; he also has a PhD.",
	"President Zachary Taylor's nickname was 'Old Rough and Ready' because of his famed war career.",
	"Andrew Jackson was once given a 1,400-pound cheese wheel as a gift, which he served at his outgoing President's Reception.",
	"Blueberry jelly beans were created for Ronald Reagan’s presidential inauguration in 1981.",
	"Dwight D. Eisenhower was the first Texas-born president.",
	"Lyndon Johnson's family all had the initials LBJ.",
	"Thomas Jefferson was convinced that if he soaked his feet in a bucket of cold water every day, he’d never get sick.",
	"Gerald Ford worked as a fashion model during college and actually appeared on the cover of Cosmopolitan.",
	"Dwight Eisenhower was the only president to serve in both World War I and World War II.",
	"Jimmy Carter was the first president to be born in a hospital.",
	"Calvin Coolidge liked to have his head rubbed with petroleum jelly while eating breakfast in bed, believing it was good for his health.",
	"A portion of Grover Cleveland's jaw was artificial, composed of vulcanized rubber.",
	"Russia and the United States are less than three miles apart.",
	"John Adams and Thomas Jefferson died within hours of each other on the Fourth of July in 1826.",
	"Abraham Lincoln's dog Fido was the first 'First Dog' to be photographed.",
	"President Calvin Coolidge owned two lion cubs: Tax Reduction and Budget Bureau.",
	"President Rutherford B. Hayes' cat Siam was the first Siamese cat in the U.S.",
	"President John Quincy Adams' pet alligator lived in a White House bathroom.",
	"First Lady Abigail Adams famously wrote, 'If you love me...you must love my dog.'",
	"John Adams' pets Satan and Juno were the first dogs to live in the White House.",
	"Calvin Coolidge walked pet raccoon Rebecca on a leash around the White House.",
	"More presidents have had pet birds than cats.",
	"Thomas Jefferson's pet mockingbird was trained to eat out of his mouth.",
	"Spotty Bush, an English Springer Spaniel, has been the only presidential pet to live at the White House during two different administrations.",
	"Andrew Jackson was the first president to ride on a railroad train.",
	"Pat Nixon was the first First Lady to wear pants in public.",
	"First Lady Martha Washington was the first American woman to be honored on a U.S. postage stamp.",
	"When snakes are born with two heads, they fight each other for food.",
	"Venus is the only planet to rotate clockwise.",
	"Tennessee ties with Missouri as the most neighborly state, bordered by 8 states.",
	"The cotton candy machine was invented in 1897, by a dentist.",
	"You can’t hum while plugging your nose.",
	"Elephants are afraid of bees.",
	"They used to offer goat carriage rides in Central Park.",
	"Chimps can develop their own fashion trends.",
	"Monday is the only day of the week with an anagram: dynamo.",
	"The only Michelangelo painting in the Western Hemisphere is on display in Fort Worth, TX.",
	"Humans are 1-2 centimeters taller in the morning than at night.",
	"Baby giraffes fall up to 6 feet to the ground when they are born.",
	"It takes around 200 muscles to take a step.",
	"The flamingo can only eat when its head is upside down.",
	"A bald eagle nest can weigh up to two tons.",
	"Worrying squirrels is not tolerated in Missouri.",
	"Wombat droppings are cube-shaped.",
	"Adult humans are the only mammal that can't breathe and swallow at the same time.",
	"Hens do not need a rooster to lay an egg.",
	"There are more nerve connections or 'synapses' in your brain than there are stars in our galaxy.",
	"There are more English words beginning with the letter 'S' than any other letter.",
	"There are more fake than real flamingos.",
	"The word “bride” comes from an old Proto-Germanic word meaning “to cook.”",
	"The word utopia – an ideal place – ironically comes from a Greek word meaning “no place.”",
	"Los Angeles was originally founded as El Pueblo de la Reina de Los Angeles.",
	"The woolly mammoth still roamed the earth while the pyramids were being built.",
	"Nine-banded armadillos almost always give birth to four identical quadruplets.",
	"Jellyfish don’t have brains.",
	"Jellyfish can clone themselves.",
	"The koala is the longest-sleeping animal, sleeping an average of 22 hours per day.",
	"Walruses are true party animals; they can go without sleep for 84 hours.",
	"The city of Chicago was raised by over a foot during the 1850s and ’60s without disrupting daily life.",
	"Red kangaroos can hop up to 44 mph.",
	"Arkansas has the only active diamond mine in the United States.",
	"Robert Heft, who designed the current U.S. flag in a high school project, received a B- because it 'lacked originality.'",
	"The first 18-hole golf course in America was built on a sheep farm in 1892.",
	"Most newborns will lose all the hair they are born with in the first six months of life.",
	"Ripening bananas glow an intense blue under black light.",
	"Coconut water was used as an IV drip in WWII when saline solution was in short supply.",
	"Mercury and Venus are the only planets in our solar system with no moon.",
	"Peanuts are not actually nuts but legumes.",
	"The Oscar statuette is brittanium plated with 24K gold.",
	"The only thing that can scratch a diamond is a diamond.",
	"There is a star that is a diamond of ten billion trillion trillion carats.",
	"One ounce of gold can be stretched into a thin wire measuring 50 miles.",
	"A $100,000 bill exists, but was only used by Federal Reserve Banks.",
	"10 million bricks were used to build the Empire State Building.",
	"One quarter of all the body’s bones are in the feet.",
	"Lake Havasu City, AZ, has been recorded as the hottest city in the U.S. with average summer temperatures of 94.6.",
	"Early sunscreens included ingredients like rice bran oil, iron, clay, and tar.",
	"One of the first sunscreens was sold in the 1910s under the name Zeozon.",
	"In the U.S., there is an official rock, paper, scissors league.",
	"The largest bill ever issued by the U.S. was a $100,000 bill in 1934.",
	"Kickball is referred to as “soccer-baseball” in some parts of Canada.",
	"Less than 1% of Sweden’s household waste ends up in a dump.",
	"Duck Duck Goose is called Duck Duck Grey Duck in Minnesota.",
	"There are more tigers owned by Americans than in the wild worldwide.",
	"Hawaiian pizza was actually created in Canada.",
	"A city in Greece struggles to build subway systems because they keep digging up ancient ruins.",
	"Elvis was a natural blonde.",
	"On Venus, it snows metal.",
	"Eating 600 bananas is the equivalent of one chest X-ray in terms of radiation.",
	"The potato became the first vegetable to be grown in space.",
	"The average dog can understand over 150 words.",
	"At one time, serving ice cream on cherry pie in Kansas was prohibited.",
	"Blueberries are one of the only natural foods that are truly blue in color.",
	"Blueberries are also called “star berries.”",
	"There are more varieties of blueberries than states in the U.S.",
	"Typically, blueberries become ripe after 2-5 weeks on a bush.",
	"Love blueberries. Celebrate them all year round, but especially in July, National Blueberry Month.",
	"While blueberries grow in clusters on their bush, the individual blueberries ripen at different times.",
	"The first commercial batch of blueberries came from Whitesbog, New Jersey, in 1916.",
	"The perfect blueberry should be “dusty” in color.",
	"Maine produces more wild blueberries than anywhere else in the world.",
	"75% of the U.S.’s tart cherries come from Michigan.",
	"Traverse, MI, considers itself the Cherry Capital of the World.",
	"Once cherries have been picked, they don’t ripen.",
	"Make sure to eat a chocolate-covered cherry on January 3; it’s National Chocolate-Covered Cherry Day.",
	"On average, how many cherries are in a pound? 44.",
	"The word “cherry” comes from the Turkish town of Cerasus.",
	"A cherry pie is made of about 250 cherries.",
	"Eau Claire, Michigan, is known as “The Cherry Pit Spitting Capital of the World.”",
	"The National Anthem of Greece has 158 verses.",
	"North Korea and Finland are technically separated by only one country.",
	"Australia’s first police force was made up of the most well-behaved convicts.",
	"Emergency phone number in Europe is 112.",
	"Canada's postal code for Santa Claus at the North Pole is H0H 0H0.",
	"Russia has a larger surface area than Pluto.",
	"In New Zealand, it is illegal to name your twin babies 'Fish' and 'Chips.'",
	"Chocolate bars and blue denim both originated in Guatemala.",
	"In New Zealand, parents have to run baby names by the government for approval.",
	"When a child loses their tooth in Greece, they throw it on the roof as a good luck wish that their adult teeth will be strong.",
	"Australia is the only nation to govern an entire continent and its outlying islands.",
	"No one in Greece can choose not to vote; voting is required by law for every citizen who is 18 or older.",
	"Australia has 10,685 beaches; you could visit a new beach every day for more than 29 years.",
	"China is large enough to cover about five separate time zones, but only has one national time zone since the Chinese Civil War in 1949.",
	"There is a language in Botswana that consists of mainly five types of clicks.",
	"An African elephant can turn the pages of a book with its trunk.",
	"Ancient Egyptians slept on head rests made of wood, ivory, or stone.",
	"A traffic jam once lasted for 11 days in Beijing, China.",
	"Alaska is the only state that can be typed on one row of keys.",
	"The blue in the Sistine Chapel is made of ground lapis lazuli gems and oils.",
	"'The Bridge of Eggs' built in Lima, Peru, was made of mortar that was mixed with egg whites.",
	"In South Korea, you are one year old at birth.",
	"The Great Wall of China is 13,170.7 miles long, over five times the distance from LA to NYC.",
	"The horizontal line between two numbers in a fraction is called a vinculum.",
	"The metal ring on the end of a pencil is called a ferrule.",
	"You cannot taste food until mixed with saliva.",
	"There is an uninhabited island in the Bahamas known as Pig Beach, which is populated entirely by swimming pigs.",
	"Lake Hillier, in Western Australia, is colored a bright pink.",
	"Spiked dog collars were invented by the Ancient Greeks, who used them on their sheepdogs to protect their necks from wolves.",
	"'Buffalo buffalo Buffalo buffalo buffalo buffalo Buffalo buffalo.' is a grammatically correct sentence.",
	"On Jupiter and Saturn, it rains diamonds.",
	"Nowhere in the Humpty Dumpty nursery rhyme does it say that Humpty Dumpty is an egg.",
	"Located on the Detroit River, the J.W. Wescott II is the only floating post office in the U.S. and has its own ZIP Code: 48222.",
	"Antarctica is the largest desert in the world.",
	"Tomatoes have more genes than humans.",
	"In Texas, it is legal to kill Bigfoot if you ever find it.",
	"Elephants can smell water up to 3 miles away.",
	"A snail can grow back a new eye if it loses one.",
	"You can tell a turtle’s gender by the noise it makes. Males grunt and females hiss.",
	"French poodles actually originated in Germany.",
	"Marine mammals swim by moving their tails up and down, while fish swim by moving their tails left and right.",
	"“Knocker uppers” were professionals paid to shoot peas at windows. They were replaced by alarm clocks.",
	"An average cumulus cloud weighs more than 70 adult T. rexes.",
	"Clicking your computer mouse 1,400 times burns one calorie.",
	"'Guy' was once an insult for anyone dressed in poor clothes, originating from the burning of effigies of the infamous British rebel, Guy Fawkes.",
	"The national animal of Scotland is the unicorn.",
	"The tea bag was created by accident in 1908 by Thomas Sullivan of New York.",
	"The male ostrich can roar just like a lion.",
	"A group of frogs is called an army.",
	"Corn always has an even number of rows on each ear.",
	"You are always looking at your nose; your brain just chooses to ignore it.",
	"There is a single mega-colony of ants that spans three continents, covering much of Europe, the west coast of the U.S., and the west coast of Japan.",
	"The world's largest mountain range is under the sea.",
	"The Anglo-Zanzibar war of 1896 is the shortest war on record, lasting an exhausting 38 minutes.",
	"Below the Kalahari Desert lies the world's largest underground lake.",
	"Oregon and Mexico once shared a border.",
	"Bluetooth technology was named after a 10th century Scandinavian king.",
	"A nun held one of the first PhDs in computer science.",
	"For 67 years, Nintendo only produced playing cards.",
	"The ancient Chinese carried Pekingese puppies in the sleeves of their robes.",
	"A tarantula can survive for more than two years without food.",
	"Ethiopia follows a calendar that is seven years behind the rest of the world.",
	"In Denmark, citizens have to select baby names from a list of 7,000 government-approved names.",
	"Every tweet Americans send is archived by the Library of Congress.",
	"A neuron star is as dense as stuffing 50 million elephants into a thimble.",
	"More energy from the sun hits Earth every hour than the planet uses in a year.",
	"An earthquake in 1812 caused the Mississippi River to flow backward.",
	"In 2014, the Department of Veterans Affairs was still paying a Civil War pension.",
	"In Webster's Dictionary, the longest words without repeating letters are “uncopyrightable” and “dermatoglyphics.”",
	"“Unprosperousness” is the longest word in which no letter occurs only once.",
	"“Typewriter” and “perpetuity” are the longest words that can be typed on a single line of a QWERTY keyboard.",
	"There have been three Olympic games held in countries that no longer exist.",
	"Golf is the only sport to be played on the moon.",
	"The word 'checkmate' comes from the Persian phrase meaning 'the king is dead.'",
	"The brain is the only organ in the human body without pain receptors.",
	"There is a volcano on Mars the size of Arizona.",
	"The blue whale can produce the loudest sound of any animal. At 188 decibels, the noise can be detected over 800 kilometers away.",
	"Dogs’ sense of hearing is more than ten times more acute than a human’s.",
	"A housefly hums in the key of F.",
	"Venus is the only planet in the solar system where the sun rises in the west.",
	"The state animal of Tennessee is a raccoon.",
	"If you were to stretch out a Slinky until it’s flat, it would measure 87 feet long.",
	"It's illegal in many countries to perform surgery on an octopus without anesthesia because of its intelligence.",
	"There are more trees on Earth than stars in the galaxy.",
	"Human thigh bones are stronger than concrete.",
	"Fires spread faster uphill than downhill.",
	"The Florida Everglades is the only place in the world where both alligators and crocodiles live together.",
	"Newborns can't cry actual tears. This normally occurs between 3 weeks and 3 months of life.",
	"If you could drive your car upward, you would be in space in less than an hour.",
	"The sun is actually white, but the Earth’s atmosphere makes it appear yellow.",
	"The Earth rotates at a speed of 1,040 MPH.",
	"Even when a snake has its eyes closed, it can still see through its eyelids.",
	"The word 'aegilops' is the longest word in the English language to have all of its letters in alphabetical order.",
	"Gorillas burp when they are happy.",
	"Because of metal prices, since 2006 the U.S. Mint has had to spend more to make a penny than they are worth.",
	"'Never odd or even' spelled backward is still 'Never odd or even.'",
	"In Alabama, it's illegal to carry an ice cream cone in your back pocket at any time.",
	"Alaska is the most northern, western, and eastern U.S. state.",
	"In France, it's illegal for employers to send emails after work hours.",
	"A group of raccoons is called a gaze.",
	"Pteronophobia is the fear of being tickled by feathers.",
	"Cherophobia is the fear of happiness.",
	"The vertical distance between the Earth's highest and lowest points is about 12 miles.",
	"A flock of crows is known as a murder.",
	"Dr. Seuss wrote 'Green Eggs and Ham' to win a bet with his publisher who thought he could not complete a book with only 50 words.",
	"Over 80% of the land in Nevada is owned by the U.S. government.",
	"There are more people on Facebook today than there were on the Earth 200 years ago.",
	"Mangoes have noses.",
	"Mangoes can get sunburned.",
	"Before 1859, baseball umpires sat behind home plate in rocking chairs.",
	"The shortest professional baseball player was 3 feet, 7 inches tall.",
	"The average life span of an MLB baseball is five to seven pitches.",
	"The most valuable baseball card ever is worth about $2.8 million.",
	"The paisley pattern is based on the mango.",
	"In India, mango leaves are used to celebrate the birth of a boy.",
	"A flipped coin is more likely to land on the side it started on.",
	"When sprinting, professional cyclists produce enough power to power a home.",
	"Mosquitoes prefer to bite people with Type O blood.",
	"During a typical MLB season, approximately 160,000 baseballs are used.",
	"The Bible is the world's most shoplifted book.",
	"The British pound is the world's oldest currency still in use.",
	"The Great Lakes have more than 30,000 islands.",
	"Mountain lions can whistle.",
	"While rabbits have near-perfect 360-degree panoramic vision, their most critical blind spot is directly in front of their nose.",
	"When a koala is born, it is about the size of a jelly bean.",
	"Toe wrestling is a competitive sport.",
	"There have been 85 recorded instances of a pitcher striking out four batters in one inning.",
	"3.7 million bags of ballpark peanuts are eaten every year at ballparks.",
	"Shakespeare created the name Jessica for his play 'The Merchant of Venice.'",
	"Tooth enamel is the hardest substance in the human body.",
	"The mummy of Pharaoh Ramesses II has a passport.",
	"It is physically impossible for a pig to look at the sky.",
	"There are more stars in the universe than grains of sand on earth.",
	"A caterpillar has more muscles than a human.",
	"A shrimp's heart is in its head.",
	"A human being could swim through the blood vessels of a blue whale.",
	"Light could travel around the earth nearly 7.5 times in one second.",
	"A single lightning bolt contains enough energy to cook 100,000 pieces of toast.",
	"About one in every 2,000 babies is born with teeth.",
	"Water can boil and freeze at the same time.",
	"Less than 5% of the population needs just 4-5 hours of sleep.",
	"Peanut butter can be converted into diamonds.",
	"Astronauts can't burp in space.",
	"An Immaculate Inning is when a pitcher strikes out three batters with only nine pitches.",
	"Earth is the only planet not named after a Greek or Roman god.",
	"Yawns are contagious to dogs as well as humans.",
	"In the 1960s, the U.S. government tried to turn a cat into a spy.",
	"Movie trailers used to come on at the end of movies, but no one stuck around to watch them.",
	"MLB umpires often wear black underwear, in case they split their pants.",
	"It is possible to record four outs in one-half inning of baseball.",
	"There are nine different ways to reach first base.",
	"During World War II, the U.S. military designed a grenade to be the size and weight of a baseball, since 'any young American man should be able to properly throw it.'",
	"Philadelphia zookeeper Jim Murray sent baseball scores to telegraph offices by carrier pigeon every half inning in 1883.",
	"From 1845 through 1867, home base was circular, made of iron, painted or enameled white, and 12 inches in diameter.",
	"President Bill Clinton's first presidential pitch (on April 4, 1993) was the first ever from the pitcher's mound to the catcher's mitt.",
	"Thunder is actually the sound caused by lightning.",
	"Australia is wider than the moon.",
	"85% of people only breathe out of one nostril at a time.",
	"An albatross can sleep while it flies.",
	"In a room of 23 people, there is a 50% chance that two people have the same birthday.",
	"Bubble wrap was originally invented as a wallpaper in 1957.",
	"There is a species of jellyfish that is immortal.",
	"Of the 193 members of the United Nations, Britain has invaded 171 of them.",
	"The Apollo 11 guidance computer was no more powerful than today's pocket calculator.",
	"“Sphenopalatine ganglioneuralgia” is the technical name for brain freeze.",
	"Earth is actually located inside the sun's atmosphere.",
	"The spiral shapes of sunflowers follow the Fibonacci sequence.",
	"If you drilled a hole through the earth, it would take 42 minutes to fall through it.",
	"The planet 55 Cancri e is made of diamonds and would be worth $26.9 nonillion.",
	"France used the guillotine as recently as 1977.",
	"Sloths move so slow that algae can grow on them.",
	"Zero is the only number that cannot be represented by Roman numerals.",
	"Michelangelo hated painting and wrote a poem about it.",
	"The dwarf lantern shark grows to be no bigger than a human hand.",
	"'Tools of ignorance' is a nickname for the equipment worn by catchers.",
	"More than 100 baseballs are used during a typical MLB game.",
	"Pitchers were prohibited from delivering the ball overhand for much of the 19th century.",
	"Walks were scored as hits during the 1887 season.",
	"A regulation baseball has 108 stitches.",
	"A 'can of corn' is a routine fly ball hit to an outfielder.",
	"Baseball is played in more than 100 countries.",
	"“Take Me Out to the Ballgame” was written in 1908 by Jack Norworth and Albert Von Tilzer, both of whom had never been to a baseball game.",
	"A baseball pitcher’s curveball can break up to 17 inches.",
	"MLB baseballs are rubbed in Lena Blackburne Baseball Rubbing Mud, a unique mud found only near Palmyra, New Jersey.",
	"The Metropolitan Museum of Art has over 30,000 baseball cards as part of the Jefferson R. Burdick collection.",
	"William Howard Taft, the 27th president of the U.S., began the tradition of throwing out the ceremonial first pitch in 1910.",
	"MLB National League (1876) is the oldest professional sports league that is still in existence.",
	"The first modern-day World Series game was played in 1903.",
	"The Mendoza Line is a .200 batting average.",
	"There are 13 different pitches a pitcher can throw in baseball.",
	"The first MLB All-Star Game was played in 1933.",
	"A player was once ejected from an MLB game for sleeping during the game.",
	"Baseball hits that bounced over the fence were considered home runs until the 1930s.",
	"The most home runs ever recorded in an MLB season is 73.",
	"The highest batting average ever recorded in an MLB season is .440.",
	"MLB has not had a lefty play catcher since 1989.",
	"The longest MLB game went 26 innings."
}

local nonsenseWords = {
	"lol", "i", "am", "drinking", "this", "tower", "and", "you", "should", "not", 
	"care", "about", "the", "banana", "why", "is", "sky", "green", "when", "it", 
	"rains", "fast", "computer", "running", "on", "toast", "mouse", "eats", "cheese", 
	"pizza", "dancing", "with", "chairs", "because", "nobody", "knows", "how", "to",
	"jump", "over", "the", "moon", "but", "cats", "fly", "at", "midnight", "without", 
	"shoes", "please", "call", "me", "when", "you", "see", "purple", "elephants"
}

local function getRandomFunFact()
	return funFacts[math.random(1, #funFacts)]
end

local function randomNonsenseSentence()
	local length = math.random(5, 12)
	local words = {}
	for i = 1, length do
		table.insert(words, nonsenseWords[math.random(1, #nonsenseWords)])
	end
	return table.concat(words, " ")
end

local function enableBodyGyro()
	if bodyGyro.Parent ~= HRP then
		bodyGyro.Parent = HRP
	end
end

local function disableBodyGyro()
	if bodyGyro.Parent ~= ReplicatedStorage then
		bodyGyro.Parent = ReplicatedStorage
	end
end

local function sayMessage(text)
	local channel = TextChatService.TextChannels:FindFirstChild("RBXGeneral")
	if channel then
		channel:SendAsync(text)
	end
end

local function getTool()
	-- Check Character first, then Backpack
	for _, tool in ipairs(CHARACTER:GetChildren()) do
		if tool:IsA("Tool") then
			return tool
		end
	end
	for _, tool in ipairs(LOCAL_PLAYER.Backpack:GetChildren()) do
		if tool:IsA("Tool") then
			return tool
		end
	end
	return nil
end

local function computePath(targetPos)
	path = PathfindingService:CreatePath()
	path:ComputeAsync(HRP.Position, targetPos)
	return path
end

local function followPath()
	if not path or path.Status ~= Enum.PathStatus.Success then return end
	for _, waypoint in ipairs(path:GetWaypoints()) do
		HUMANOID:MoveTo(waypoint.Position)
		local reached = false
		local conn
		conn = HUMANOID.MoveToFinished:Connect(function()
			reached = true
		end)
		while not reached and (chasing or following) do
			RunService.Heartbeat:Wait()
			if currentTarget and (currentTarget.Character.HumanoidRootPart.Position - lastTargetPos).Magnitude > 10 then
				conn:Disconnect()
				return "recompute"
			end
		end
		conn:Disconnect()
	end
end

local function faceTarget(distance)
	if currentTarget and currentTarget.Character and currentTarget.Character:FindFirstChild("HumanoidRootPart") then
		local dir = (currentTarget.Character.HumanoidRootPart.Position - HRP.Position).Unit
		local yawOnly = CFrame.new(Vector3.zero, Vector3.new(dir.X, 0, dir.Z))

		if distance and distance <= 14 and chasing then
			local wiggleSpeed = 55
			local wiggleAmount = math.clamp((14 - distance) / 14, 0, 1) * 0.6
			local t = tick() * wiggleSpeed
			local offsetYaw = math.sin(t) * wiggleAmount
			bodyGyro.CFrame = yawOnly * CFrame.Angles(0, offsetYaw, 0)
		else
			bodyGyro.CFrame = yawOnly
		end
	end
end

local function wiggleMove(distance)
	local speed = 55
	local intensity = math.clamp((14 - distance) / 14, 0, 1) * 25
	local t = tick() * speed
	HUMANOID:Move(Vector3.new(math.sin(t) * intensity, 0, 0))
end

local function scribbleMove()
	local t = tick()
	HUMANOID:Move(Vector3.new(math.sin(t * 25), 0, math.cos(t * 30)))
end

local function strafeSequence()
	strafeActive = true
	local jump = math.random(1, 2) == 1
	local repeats = math.random(1, 2)
	for i = 1, repeats do
		local x = math.random(-1, 1)
		local z = math.random(-1, 1)
		local vec = Vector3.new(x, 0, z)
		if vec.Magnitude == 0 then vec = Vector3.new(1, 0, 0) end
		vec = vec.Unit
		HUMANOID:Move(vec)
		if jump then
			HUMANOID.Jump = true
			wait(0.25)
			HUMANOID.Jump = false
		end
		wait(0.3)
	end
	strafeActive = false
end

local function walkToCommander()
	if currentCommander and currentCommander.Character and currentCommander.Character:FindFirstChild("HumanoidRootPart") then
		local pos = currentCommander.Character.HumanoidRootPart.Position
		HUMANOID:MoveTo(pos + Vector3.new(0, 0, 10))
	end
end

local function sortTargetsByDistance(t)
	table.sort(t, function(a, b)
		local aHRP = a.Character and a.Character:FindFirstChild("HumanoidRootPart")
		local bHRP = b.Character and b.Character:FindFirstChild("HumanoidRootPart")
		if aHRP and bHRP then
			return (aHRP.Position - HRP.Position).Magnitude < (bHRP.Position - HRP.Position).Magnitude
		end
		return false
	end)
end

local function getPlayerByPartialName(name)
	name = name:lower()
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LOCAL_PLAYER and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
			if player.Name:lower():find(name) then
				return player
			end
		end
	end
end

local function parseTargetsList(message)
	message = message:lower()
	if message == "others" then
		local r = {}
		for _, p in ipairs(Players:GetPlayers()) do
			if p ~= LOCAL_PLAYER and not WHITELIST[p.Name] then
				table.insert(r, p)
			end
		end
		return r

	elseif message == "all" or message == "everyone" then
		local r = {}
		for _, p in ipairs(Players:GetPlayers()) do
			if p ~= LOCAL_PLAYER then
				table.insert(r, p)
			end
		end
		return r
		
	elseif message == "ran" or message == "rand" or message == "random" then
		local r = {}
		for _, p in ipairs(Players:GetPlayers()) do
			if p ~= LOCAL_PLAYER then
				table.insert(r, p)
			end
		end
		return { r[math.random(1, #r)] }
	elseif message:find(" and ") then
		local r = {}
		for name in string.gmatch(message, "[^%s]+") do
			if name ~= "and" then
				local found = getPlayerByPartialName(name)
				if found then
					table.insert(r, found)
				end
			end
		end
		return r

	else
		local single = getPlayerByPartialName(message)
		if single then return { single } end
	end

	return {}
end

local function killPlayer(targetPlayer)
	local tool = getTool()
	if not tool then
		sayMessage("tool required to kill " .. targetPlayer.Name)
		return
	end

	tool.Parent = CHARACTER
	enableBodyGyro()

	currentTarget = targetPlayer
	chasing = true
	local startTime = tick()

	while chasing and currentTarget and currentTarget.Character and currentTarget.Character:FindFirstChild("HumanoidRootPart") do
		local hrp = currentTarget.Character.HumanoidRootPart
		local distance = (HRP.Position - hrp.Position).Magnitude

		faceTarget(distance)
		
		if HUMANOID.Sit then
			HUMANOID.Jump = true
		end

		if distance <= 35 then
			pcall(function()
				tool:Activate()
			end)
		end

		if distance >= 43.5 and math.random(1, 5) == 1 and not strafeActive then
			task.spawn(strafeSequence)
		end

		if distance > 14 then
			lastTargetPos = hrp.Position
			computePath(lastTargetPos)
			local result = followPath()
			if result == "recompute" then continue end
		else
			if distance <= 14 then
				wiggleMove(distance)
			elseif distance <= 5 then
				scribbleMove()
			else
				HUMANOID:Move(Vector3.new(0, 0, 0))
			end
		end

		if currentTarget.Character:FindFirstChildOfClass("Humanoid").Health <= 0 then
			sayMessage("Successfully killed " .. currentTarget.Name)
			chasing = false
			break
		end

		if tick() - startTime >= 60 then
			sayMessage("Failed to kill " .. currentTarget.Name)
			chasing = false
			break
		end

		RunService.Heartbeat:Wait()
	end

	HUMANOID:UnequipTools()
	disableBodyGyro()
	wait(0.5)
	walkToCommander()
	currentTarget = nil
end

local function killMultiplePlayers(targets)
	sortTargetsByDistance(targets)
	for _, player in ipairs(targets) do
		if not chasing then break end
		killPlayer(player)
	end
end

local function followPlayer(targetPlayer)
	currentTarget = targetPlayer
	following = true

	while following and currentTarget and currentTarget.Character and currentTarget.Character:FindFirstChild("HumanoidRootPart") do
		local hrp = currentTarget.Character.HumanoidRootPart
		local distance = (HRP.Position - hrp.Position).Magnitude
		
		if HUMANOID.Sit then
			HUMANOID.Jump = true
		end

		if distance > 5 then
			lastTargetPos = hrp.Position
			computePath(lastTargetPos)
			local result = followPath()
			if result == "recompute" then continue end
		else
			HUMANOID:Move(Vector3.new(0,0,0))
		end

		RunService.Heartbeat:Wait()
	end

	currentTarget = nil
end

local function followMultiplePlayers(targets)
	sortTargetsByDistance(targets)
	for _, player in ipairs(targets) do
		if not following then break end
		followPlayer(player)
	end
end

local trollEmotes = {
	"/e dance", "/e laugh", "/e point", "/e wave", "/e cheer"
}

local function trollBehavior()
	trolling = true
	while trolling do
		local x = math.random(-100, 100)
		local z = math.random(-100, 100)
		HUMANOID:MoveTo(HRP.Position + Vector3.new(x, 0, z))
		sayMessage(trollEmotes[math.random(1, #trollEmotes)])
		wait(math.random(5, 10))
	end
end

local function nonsenseBehavior()
	nonsenseMode = true
	task.spawn(trollBehavior)
	while nonsenseMode do
		sayMessage(randomNonsenseSentence())
		wait(math.random(4, 7))
	end
end

local function onCopyChatted(player, msg)
	if copyingPlayer and player == copyingPlayer then
		sayMessage(msg)
	end
end

local function wander()
	wandering = true
	while wandering do
		local x = math.random(-100, 100)
		local z = math.random(-100, 100)
		computePath(Vector3.new(x,0,z))
		sayMessage("Wandering to " .. "x: " .. x .. ", z: " .. z)
		wait(math.random(1, 5))
	end
end

local function stareAt(player)
	if not player or not player.Character then return end
	local hrp = player.Character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	staring = true
	enableBodyGyro()
	if bodyGyro.Parent ~= HRP then
		bodyGyro.Parent = HRP
	end

	while staring and player.Character and player.Character:FindFirstChild("HumanoidRootPart") do
		local dir = (hrp.Position - HRP.Position).Unit
		local yawOnly = CFrame.new(Vector3.new(), Vector3.new(dir.X, 0, dir.Z))
		bodyGyro.CFrame = yawOnly
		RunService.Heartbeat:Wait()
	end

	disableBodyGyro()
end

local copyingConnection = nil

local function onChatted(sender, message)
	if not WHITELIST[sender.Name] then return end
	if not message:lower():sub(1, 4) == "ai: " then return end

	currentCommander = sender
	message = message:sub(5):lower()

	if message:sub(1, 5) == "kill " then
		local targets = parseTargetsList(message:sub(6))
		if #targets > 0 then
			following = false
			trolling = false
			nonsenseMode = false
			copyingPlayer = nil
			wandering = false
			staring = false
			chasing = true
			task.spawn(killMultiplePlayers, targets)
		end

	elseif message:sub(1, 7) == "follow " then
		local targets = parseTargetsList(message:sub(8))
		if #targets > 0 then
			chasing = false
			trolling = false
			nonsenseMode = false
			copyingPlayer = nil
			wandering = false
			staring = false
			following = true
			task.spawn(followMultiplePlayers, targets)
		end

	elseif message == "stop" or message == "freeze" or message == "abort" then
		chasing = false
		following = false
		trolling = false
		nonsenseMode = false
		wandering = false
		staring = false
		copyingPlayer = nil
		disableBodyGyro()
		sayMessage("Stopped.")

	elseif message == "troll" then
		chasing = false
		following = false
		nonsenseMode = false
		copyingPlayer = nil
		wandering = false
		staring = false
		trolling = true
		task.spawn(trollBehavior)

	elseif message == "nonsense" then
		chasing = false
		following = false
		trolling = false
		copyingPlayer = nil
		wandering = false
		staring = false
		nonsenseMode = true
		task.spawn(nonsenseBehavior)
	elseif message:sub(1, 5) == "copy " then
		local pName = message:sub(6)
		local p = getPlayerByPartialName(pName)
		if p then
			chasing = false
			following = false
			trolling = false
			wandering = false
			staring = false
			nonsenseMode = false

			if copyingConnection then
				copyingConnection:Disconnect()
				copyingConnection = nil
			end

			copyingPlayer = p
			copyingConnection = p.Chatted:Connect(function(msg)
				if copyingPlayer == p then
					sayMessage(msg)
				end
			end)
			sayMessage("Copying " .. p.Name)
		end
	elseif message == "fact" or message == "fun fact" or message == "fax" then
		sayMessage(getRandomFunFact())
	elseif message == "wander" then
		chasing = false
		following = false
		trolling = false
		copyingPlayer = nil
		nonsenseMode = false
		staring = false
		wandering = true
		task.spawn(wander)
	elseif message:sub(1, 7) == "stareat" then
		local targets = parseTargetsList(message:sub(8))
		if #targets > 0 then
			chasing = false
			following = false
			trolling = false
			nonsenseMode = false
			copyingPlayer = nil
			wandering = false
			staring = true

			local target = targets[1]

			task.spawn(function()
				stareAt(target)
			end)
		end
	end
end

Players.PlayerAdded:Connect(function(p)
	if WHITELIST[p.Name] then
		p.Chatted:Connect(function(msg)
			onChatted(p, msg)
		end)
	end
end)

for _, p in ipairs(Players:GetPlayers()) do
	if WHITELIST[p.Name] then
		p.Chatted:Connect(function(msg)
			onChatted(p, msg)
		end)
	end
end

local function setupCharacter(character)
	CHARACTER = character
	HUMANOID = character:WaitForChild("Humanoid")
	HRP = character:WaitForChild("HumanoidRootPart")
	disableBodyGyro()
	currentTarget = nil
	chasing = false
	following = false
	trolling = false
	nonsenseMode = false
	copyingPlayer = nil
end

LOCAL_PLAYER.CharacterAdded:Connect(setupCharacter)

if LOCAL_PLAYER.Character then
	setupCharacter(LOCAL_PLAYER.Character)
end
