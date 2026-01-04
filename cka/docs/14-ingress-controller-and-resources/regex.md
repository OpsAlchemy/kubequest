# Regex From Absolute Scratch - You WILL Understand This 🎯

## 🎪 PART 1: The Absolute Basics

### 🤔 What is Regex?
It's just **text pattern matching**. Like CTRL+F but more powerful.

```
cat
```
This matches: "cat" in "I have a **cat**", "concatenate", "catch"

---

## 🧱 PART 2: The 6 Things You Actually Need

### 1️⃣ Literal Characters
The letter `a` matches the letter `a`. That's it.

```
dog
```
✅ "I have a **dog**"  
✅ "hot**dog**"  
✅ "**dog**matic"  
❌ "DOG" (case sensitive by default)  
❌ "d og" (needs exact letters together)

### 2️⃣ The Dot `.` = ANY SINGLE CHARACTER
```
d.g
```
✅ "**dog**" (d, then o, then g)  
✅ "**dig**" (d, then i, then g)  
✅ "**dug**" (d, then u, then g)  
❌ "dg" (needs something between d and g)  
❌ "dogg" (too many characters)

### 3️⃣ Star `*` = ZERO OR MORE of previous thing
```
do*g
```
✅ "**dg**" (zero 'o's)  
✅ "**dog**" (one 'o')  
✅ "**doog**" (two 'o's)  
✅ "**dooooog**" (many 'o's)

**💡 Common pattern: `.*` = ANYTHING (zero or more of any character)**
```
d.*g
```
✅ "**dg**"  
✅ "**dog**"  
✅ "**d123g**"  
✅ "**d anything here g**"

### 4️⃣ Plus `+` = ONE OR MORE of previous thing
```
do+g
```
✅ "**dog**" (one 'o')  
✅ "**doog**" (two 'o's)  
✅ "**dooooog**" (many 'o's)  
❌ "**dg**" (needs at least one 'o')

### 5️⃣ Question Mark `?` = ZERO OR ONE of previous thing
```
dogs?
```
✅ "**dog**" (zero 's')  
✅ "**dogs**" (one 's')  
❌ "**dogss**" (too many 's's)

### 6️⃣ Square Brackets `[ ]` = ANY ONE OF these characters
```
b[aeiou]t
```
✅ "**bat**"  
✅ "**bet**"  
✅ "**bit**"  
✅ "**bot**"  
✅ "**but**"  
❌ "**bxt**" (x not in the list)

**📏 Ranges:**
```
[0-9]       # Any single digit
[a-z]       # Any lowercase letter
[A-Z]       # Any uppercase letter
[a-zA-Z]    # Any letter
[a-z0-9]    # Any lowercase letter or digit
```

**🔥 Negation in brackets `[^ ]`:**
```
[^aeiou]    # Any character EXCEPT a,e,i,o,u
[^0-9]      # Any character EXCEPT digits
```

---

## 🏗️ PART 3: Let's Build Something Real

### 📅 Example 1: Find dates like "Jan 15, 2023"
```
[A-Z][a-z][a-z] [0-9]+, [0-9][0-9][0-9][0-9]
```
**🔍 Breakdown:**
- `[A-Z]` - One uppercase letter (J)
- `[a-z][a-z]` - Two lowercase letters (an)
- Space
- `[0-9]+` - One or more digits (15)
- `,` - Comma
- Space
- `[0-9][0-9][0-9][0-9]` - Four digits (2023)

✅ "**Jan 15, 2023**"  
✅ "**Dec 1, 1999**"  
❌ "Jan 15 2023" (missing comma)

### 📞 Example 2: Find phone numbers (xxx) xxx-xxxx
```
\([0-9][0-9][0-9]\) [0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]
```
**✨ Better with `{n}` quantifier:**
```
\([0-9]{3}\) [0-9]{3}-[0-9]{4}
```
`{3}` means "exactly 3 times"

✅ "(**123) 456-7890**"  
❌ "(12) 456-7890" (only 2 digits in area code)

### 🌐 Example 3: Find URLs starting with http or https
```
https?://[a-zA-Z0-9.-]+
```
**🔍 Breakdown:**
- `http` literal
- `s?` optional 's' (http OR https)
- `://` literal
- `[a-zA-Z0-9.-]+` one or more letters, digits, dots, or hyphens

✅ "**https://google.com**"  
✅ "**http://example.com**"  
❌ "htt://example.com" (missing p)

---

## 🎯 PART 4: Special Characters You Need

### `^` = START of line
```
^Hello
```
✅ "**Hello** world" (at start)  
❌ "Say **Hello**" (not at start)

### `$` = END of line
```
world$
```
✅ "Hello **world**" (at end)  
❌ "**world** hello" (not at end)

**💡 Common: `^...$` = ENTIRE line must match**
```
^[0-9]+$
```
✅ "**123**" (entire line is digits)  
❌ "**123 abc**" (has non-digits)

### `\d` = DIGIT (same as [0-9])
```
\d\d\d-\d\d\d-\d\d\d\d
```
Same as: `[0-9][0-9][0-9]-[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]`

### `\w` = WORD character (letter, digit, or underscore)
```
\w+
```
✅ "**hello**", "**user123**", "**my_name**"

### `\s` = WHITESPACE (space, tab, newline)
```
hello\sworld
```
✅ "**hello world**", "**hello(tab)world**"

### `\b` = WORD BOUNDARY
```
\bcat\b
```
✅ "The **cat** sat"  
❌ "**cat**alog" (cat not at word boundary)

---

## 🎪 PART 5: CAPTURE GROUPS - The Magic `( )`

### 🎯 Basic Capture Groups
Parentheses `( )` capture text for later use:

```
Name: (\w+)
```
Text: "Name: John"  
Captures: `$1 = "John"`

```
(\d+)-(\d+)-(\d+)
```
Text: "123-456-7890"  
Captures: `$1 = "123"`, `$2 = "456"`, `$3 = "7890"`

### 🔄 BACKREFERENCES - Reuse captured groups
Use `\1`, `\2`, etc., to reference captured groups:

```
(\w+) \1
```
✅ "**hello hello**" (same word twice)  
✅ "**test test**"  
❌ "hello world"

```
(['"])(.*?)\1
```
✅ "**'hello'**" (same quote start and end)  
✅ '**"world"**'  
❌ "'hello" (quotes don't match)

### 📝 NAMED CAPTURE GROUPS `(?P<name>...)`
Give your groups names:

```
(?P<year>\d{4})-(?P<month>\d{2})-(?P<day>\d{2})
```
Text: "2023-12-25"  
Captures: `year=2023`, `month=12`, `day=25`

### 🚫 Non-capturing group `(?: )`
Use when you need grouping but don't want to capture:
```
(?:Mr|Ms|Mrs)\. (\w+)
```
Text: "Mr. Smith"  
Captures: `$1 = "Smith"` (only the name, not the title)

**💡 Why use non-capturing?**
- Faster performance
- Cleaner backreference numbering
- When you just need grouping for alternation

### 🎭 LOOKAROUNDS - Magic without consuming characters

**Positive Lookahead `(?=...)`** - Must have this AFTER, but don't include in match:
```
\w+(?=\.com)
```
Text: "google.com yahoo.com"  
Matches: "**google**", "**yahoo**" (but not the .com)

**Negative Lookahead `(?!...)`** - Must NOT have this AFTER:
```
\w+(?!\.com)
```
Text: "google.com example.org"  
Matches: "**example**" (but not google)

**Positive Lookbehind `(?<=...)`** - Must have this BEFORE:
```
(?<=\$)\d+
```
Text: "Price: $100 and $200"  
Matches: "**100**", "**200**" (dollar sign not included)

**Negative Lookbehind `(?<!...)`** - Must NOT have this BEFORE:
```
(?<!\$)\d+
```
Text: "Price $100 and weight 200"  
Matches: "**200**" (not preceded by $)

---

## 🏗️ PART 6: Real Examples Step by Step

### 📧 Build an email validator:
```
Step 1: Username part
\w+                         # One or more word characters

Step 2: Add @ symbol
\w+@                        # username@

Step 3: Domain name
\w+@\w+                     # username@domain

Step 4: Add dot and extension
\w+@\w+\.\w+               # username@domain.com

Step 5: Allow dots in username
[\w\.]+@\w+\.\w+           # first.last@domain.com

Step 6: Allow hyphens in domain
[\w\.]+@[\w-]+\.\w+        # first.last@my-domain.com

Step 7: Multiple extensions (like .co.uk)
[\w\.]+@[\w-]+(?:\.[\w-]+)+  # user@domain.co.uk

Final:
^[\w\.]+@[\w-]+(?:\.[\w-]+)+$
```

### 🔗 Build a URL path matcher for /api/v1/users/123:
```
Step 1: Start with /api
^/api

Step 2: Add version /v1
^/api/v[0-9]+

Step 3: Add resource /users
^/api/v[0-9]+/[a-z]+

Step 4: Add ID /123 (optional with ?)
^/api/v[0-9]+/[a-z]+(?:/\d+)?

Step 5: Capture parts
^/api/v([0-9]+)/([a-z]+)(?:/(\d+))?

Final:
^/api/v(\d+)/(\w+)(?:/(\d+))?$
# Captures: version, resource, optional ID
```

---

## 🌟 PART 7: More Practical Examples

### 🌐 Example 4: Match HTML tags (basic)
```
<[^>]+>
```
Matches: `<div>`, `<span class="test">`, `</p>`

### 📡 Example 5: Match IP addresses
```
\b(?:\d{1,3}\.){3}\d{1,3}\b
```
Matches: "192.168.1.1", "10.0.0.1"

### 💳 Example 6: Match credit card numbers (basic pattern)
```
\d{4}[- ]?\d{4}[- ]?\d{4}[- ]?\d{4}
```
Matches: "1234-5678-9012-3456", "1234 5678 9012 3456", "1234567890123456"

### 🎨 Example 7: Match hexadecimal color codes
```
#(?:[0-9a-fA-F]{3}){1,2}
```
Matches: "#fff", "#ffffff", "#abc123"

### 🔢 Example 8: Match version numbers
```
v?\d+(?:\.\d+)+(?:-[a-zA-Z0-9]+)?
```
Matches: "1.0.0", "v2.1.3", "3.14.15-beta"

### 📁 Example 9: Match file paths
```
(?:/[^/]+)+/[\w\-\.]+\.\w+
```
Matches: "/home/user/file.txt", "/var/log/app.log", "/path/to/my-file_v1.2.pdf"

### 🐦 Example 10: Match Twitter handles
```
@\w{1,15}
```
Matches: "@username", "@john_doe123"

### 🆔 Example 11: Match UUIDs
```
[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}
```
Matches: "550e8400-e29b-41d4-a716-446655440000"

### 📊 Example 12: Match CSV values
```
"[^"]*"|[^,]+
```
Text: 'John,"Doe, Jr.",30,"New York, NY"'  
Matches: "John", '"Doe, Jr."', "30", '"New York, NY"'

### 🔍 Example 13: Extract all links from HTML
```
<a\s+(?:[^>]*?\s+)?href="([^"]*)"[^>]*>
```
Extracts URLs from `<a href="...">` tags

---

## 🎯 PART 8: Complex Patterns & Advanced Examples

### 🎭 Example 14: Password Validation
```
^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$
```
**🔍 Breakdown:**
- `^` start
- `(?=.*[A-Z])` at least one uppercase (lookahead)
- `(?=.*[a-z])` at least one lowercase
- `(?=.*\d)` at least one digit
- `(?=.*[@$!%*?&])` at least one special char
- `[A-Za-z\d@$!%*?&]{8,}` 8+ chars from allowed set
- `$` end

### 🗓️ Example 15: Date Validation (YYYY-MM-DD)
```
^(?:(?:19|20)\d\d)-(?:0[1-9]|1[0-2])-(?:0[1-9]|[12][0-9]|3[01])$
```
**🔍 Breakdown:**
- `(?:19|20)\d\d` years 1900-2099
- `(?:0[1-9]|1[0-2])` months 01-12
- `(?:0[1-9]|[12][0-9]|3[01])` days 01-31

### 🔗 Example 16: Complex URL Parser
```
^((https?|ftp):\/\/)?([\w\-]+\.)+[\w\-]+(:\d+)?(\/[\w\-\.\/?#&%=]*)?$
```
**🔍 Breakdown:**
- `((https?|ftp):\/\/)?` optional protocol
- `([\w\-]+\.)+[\w\-]+` domain
- `(:\d+)?` optional port
- `(\/[\w\-\.\/?#&%=]*)?` optional path

### 🧮 Example 17: Arithmetic Expression Validator
```
^\s*(\d+(?:\.\d+)?)\s*([+\-*/])\s*(\d+(?:\.\d+)?)\s*$
```
Matches: "5 + 3", "10.5 * 2.3", "100 / 25"

### 📝 Example 18: Extract JavaScript Function Definitions
```
function\s+(\w+)\s*\(([^)]*)\)\s*{
```
Matches: `function myFunc(arg1, arg2) {`

### 🗂️ Example 19: Parse Log File Entries
```
^(\d{4}-\d{2}-\d{2}\s\d{2}:\d{2}:\d{2})\s+(\w+)\s+\[(\w+)\]\s+(.*)$
```
Parses: `2023-12-25 10:30:00 INFO [Main] User logged in`

### 🎮 Example 20: Game Coordinate Parser
```
\((-?\d+(?:\.\d+)?),\s*(-?\d+(?:\.\d+)?),\s*(-?\d+(?:\.\d+)?)\)
```
Matches: `(10.5, -20.3, 5.0)`

---

## 🎪 PART 9: Practice Problems - Try These

### 🕐 Problem 1: Match time "HH:MM" (24-hour format)
```
Your answer: ________

Should match: "14:30", "09:45", "23:59"
Should NOT match: "24:00", "14:60", "abc"
```

**✅ Solution:**
```
^(?:[01][0-9]|2[0-3]):[0-5][0-9]$
```
**🔍 Breakdown:**
- `^` start
- `(?:[01][0-9]|2[0-3])` hours: 00-19 OR 20-23
- `:` literal colon
- `[0-5][0-9]` minutes: 00-59
- `$` end

### 🏷️ Problem 2: Match hashtags in text
Text: "I love #coding and #regex101"
Should match: "#coding", "#regex101"

**✅ Solution:**
```
#\w+
```

### 💰 Problem 3: Extract prices "$19.99" or "€25"
```
[$€]?\d+(?:\.\d{2})?
```
**🔍 Breakdown:**
- `[$€]?` optional $ or €
- `\d+` one or more digits
- `(?:\.\d{2})?` optional . followed by exactly 2 digits

### 🗣️ Problem 4: Find all words in quotes
Text: 'Hello' and "World" and `Code`
Should match: "Hello", "World", "Code"

**✅ Solution:**
```
['"`]([^'"`]+)['"`]
```

### 🔌 Problem 5: Match MAC addresses
```
(?:[0-9A-Fa-f]{2}[:-]){5}[0-9A-Fa-f]{2}
```
Matches: "00:1A:2B:3C:4D:5E", "00-1A-2B-3C-4D-5E"

---

## ⚠️ PART 10: Common Pitfalls & Fixes

### 🔥 1. Greedy vs Lazy Quantifiers
By default: `.*` is GREEDY (takes as much as possible)
```
<.*>
```
Text: "<div>hello</div><p>world</p>"  
Matches: "**<div>hello</div><p>world</p>**" (the WHOLE thing!)

**✅ Fix: Use `.*?` for LAZY (takes as little as possible)**
```
<.*?>
```
Matches: "**<div>**" and "**</div>**" and "**<p>**" and "**</p>**" separately

### 🛡️ 2. Escaping Special Characters
If you want to match literal `.` or `*` or `?`, escape with `\`
```
File: report\.pdf
```
Matches "**report.pdf**" not "**reportapdf**"

### ⏱️ 3. Performance Issues
**❌ Bad (catastrophic backtracking):**
```
(.*)*=(.*)*
```
**✅ Good (efficient):**
```
[^=]*=[^=]*
```

### 🎯 4. Anchoring for Validation
**❌ Bad (might match partial string):**
```
\d{3}-\d{3}-\d{4}
```
Could match: "abc123-456-7890def"

**✅ Good (full string validation):**
```
^\d{3}-\d{3}-\d{4}$
```

---

## 📊 PART 11: Quick Reference Card

| Symbol | Means | Example |
|--------|-------|---------|
| `.` | Any single character | `d.g` → dog, dig, dug |
| `*` | Zero or more | `do*g` → dg, dog, doog |
| `+` | One or more | `do+g` → dog, doog |
| `?` | Zero or one | `dogs?` → dog, dogs |
| `{n}` | Exactly n times | `\d{3}` → 123 |
| `{n,}` | n or more times | `\d{3,}` → 123, 1234 |
| `{n,m}` | n to m times | `\d{2,4}` → 12, 123, 1234 |
| `[abc]` | Any of a,b,c | `[aeiou]` → a,e,i,o,u |
| `[^abc]` | Not a,b,c | `[^aeiou]` → b,c,d,f |
| `[a-z]` | Any lowercase | `[a-z]` → a,b,c...z |
| `\d` | Digit | `\d` → 0-9 |
| `\D` | Not digit | `\D` → a,b,c,... |
| `\w` | Word char | `\w` → a-z,A-Z,0-9,_ |
| `\W` | Not word char | `\W` → !,@,#,$ |
| `\s` | Whitespace | `\s` → space, tab |
| `\S` | Not whitespace | `\S` → a,b,1,2 |
| `\b` | Word boundary | `\bcat\b` → matches "cat" |
| `\B` | Not word boundary | `\Bcat\B` → matches "scatter" |
| `^` | Start of line | `^Hello` → Hello at start |
| `$` | End of line | `end$` → end at end |
| `( )` | Capture group | `(\d+)` → captures 123 |
| `(?: )` | Non-capture group | `(?:\d+)` → groups but no capture |
| `(?= )` | Positive lookahead | `\d(?=px)` → digit before px |
| `(?! )` | Negative lookahead | `\d(?!px)` → digit not before px |
| `(?<= )` | Positive lookbehind | `(?<=\$)\d` → digit after $ |
| `(?<! )` | Negative lookbehind | `(?<!\$)\d` → digit not after $ |
| `\|` | OR | `cat|dog` → cat OR dog |

---

## 🚀 PART 12: Your Practice Routine

### 📅 Day 1-3: Literals and Basic Symbols
Practice with:
```bash
echo "The cat sat on the mat" | grep -o "cat"
echo "dog dig dug" | grep -E "d.g"
echo "dg dog doog doooog" | grep -E "do*g"
```

### 📅 Day 4-7: Character Classes and Groups
```bash
# Find phone numbers
echo "Call 123-456-7890 or 555-1234" | grep -E "[0-9]{3}-[0-9]{3}-[0-9]{4}"

# Find email addresses
echo "Email me at test@example.com or admin@site.org" | grep -E "\w+@\w+\.\w+"

# Extract dates
echo "Dates: 2023-12-25, 1999-01-01, 2024-02-30" | grep -E "\d{4}-\d{2}-\d{2}"
```

### 📅 Day 8-10: Advanced Patterns
```bash
# Validate passwords
echo "Pass: Abc123! Test456? Weak pass" | grep -E "(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[!@#$%^&*]).{8,}"

# Parse log files
echo "2023-12-25 10:30:00 ERROR [Auth] Login failed" | grep -E "^(\d{4}-\d{2}-\d{2}\s\d{2}:\d{2}:\d{2})\s+(\w+)\s+\[(\w+)\]\s+(.*)$"
```

### 📅 Day 11-14: Real Projects
1. Extract all links from HTML
2. Validate form inputs (email, phone, password)
3. Parse log files
4. Search and replace in code
5. Data cleaning and transformation

---

## 💡 THE ONE SENTENCE TO REMEMBER:

**"Regex is just patterns: `.` means any character, `*` means repeat, `[ ]` means choose, `( )` means group, and `^$` anchor the ends."**

---

## 🎮 Need to practice RIGHT NOW?
```bash
# Quick test environment
cat > test.txt << EOF
Hello world
test@example.com
Phone: 123-456-7890
Date: 2023-12-25
#hashtag1 #hashtag2
Password: Abc123!
Log: 2023-12-25 10:30:00 INFO [Main] Started
Coordinates: (10.5, 20.3, 5.0)
EOF

# Try these:
grep -E "#\w+" test.txt           # Find hashtags
grep -E "\d{3}-\d{3}-\d{4}" test.txt # Find phone numbers
grep -E "\w+@\w+\.\w+" test.txt   # Find emails
grep -E "^[\w\.]+@[\w-]+(?:\.[\w-]+)+$" test.txt # Validate email format
grep -E "\([^)]+\)" test.txt      # Find things in parentheses
```

**🎯 Start with simple patterns. Get them working. Then add complexity. You'll be a regex expert in 10 days!**