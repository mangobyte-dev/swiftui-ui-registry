# Case studies: four small apps built by an agent

In September 2026 we asked an AI coding agent to build four small iPhone apps from this registry. We counted how often something got in its way, changed the registry one thing at a time, and measured again. This page shows the four apps, the items they used, and what the measurement found. The changes it led to shipped in 0.4.0.

The apps are not in this repository. The screenshots below come from the agent's own builds, opened screen by screen on an iPhone 17 simulator.

## How the measurement worked

- The agent was Claude Opus 4.8, running inside Claude Code with the `swiftui-registry` tool, the consumer skill, the registry specification, and the catalog. It got a short brief per app and nothing else.
- Every brief asked for four screens, mock data, plain `@State`, one file per screen, and a launch argument that opens any screen directly.
- A script read the agent's transcript and counted seven kinds of friction. In plain words: reading installed source instead of the docs, searches that found nothing, repeated commands, compile errors, edits made to guess past a compile error, views written by hand that an item already covers, and documentation gaps the agent reported with evidence.
- A gate checked each finished app: it builds, every screen opens by launch argument, and the required items are installed and used. Every one of the 246 runs across the study passed the gate.
- Each app was built five times per registry state. The score is the median of those runs, so one unlucky run does not decide the result.
- A second group of runs used plain SwiftUI with no registry, tool, or skill, as the reference.

## What the numbers say

Friction per app, median of the runs. Lower is better, 0 means nothing got in the way.

| Setup | Shop | Chat | Settings | Finance |
| --- | --- | --- | --- | --- |
| Plain SwiftUI, no registry | 1 | 7 | 1 | 6 |
| Registry at the start of the study | 3 | 4 | 3 | 5 |
| Registry with the 0.4.0 changes | 1 | 0 | 0 | 0 |

The three rows tell three different stories.

- **Plain SwiftUI** scored on one thing only: views the agent wrote by hand that the registry already has. Across the twelve plain runs it hand built 44 such views by the agent judge's count, 47 by the classifier's. The most common were list rows, badges, metric cards, charts, transaction rows, skeletons, checkboxes, and toasts. The chat and finance briefs cost the most because they have the most of those.
- **The registry before the changes** never hand built a view. Not once, in any run. Its friction was almost all searches that found nothing: the agent searched for the words a developer says first (`product`, `cart`, `unread`, `sign out`, `filter`, `total`) and the items were named `item`, `badge`, `alert-dialog`, `accordion`, and `metric-card`.
- **The registry with the 0.4.0 changes** brought three of the four apps to zero. The one remaining point in Shop is a search for `quantity`. Nothing matches it on purpose: the native `Stepper` is the right control, and we chose not to add an item that only renames it.

The rows are not a race between plain SwiftUI and the registry. They show where each one loses time. Plain SwiftUI loses it writing components. The registry lost it on naming and on a few sharp edges in the API, and those were cheap to fix.

## What changed because of this

The study had a warm up: one Shop build from the released 0.3.1 tool, read by hand. It found seven problems and they were fixed the same day. Three of them matter here:

- `search` says `No item matches` instead of printing nothing, so the agent stops retrying.
- Thirteen items gained the words a shop developer searches first, such as `product`, `cart`, and `price`.
- Every usage snippet now compiles in the Showcase. Five of them had named state they never declared.

The four app study then ran on that fixed registry. Each change below was kept only when the median fell for the app it targeted and no other count rose. All of them are in 0.4.0.

| Change | What the agent hit | Apps it helped |
| --- | --- | --- |
| Fourteen more items gained first guess words: `unread`, `composer`, `sign out`, `notifications`, `filter`, `range`, `total`, `refresh` | Searches for those words found nothing | Chat, Settings, Finance |
| `describe` prints every public signature with its owning type and enum cases | The agent read installed source to learn a nested type such as `TransactionRow.Tone` | Finance, Chat |
| `Field` takes its error as a `String?` | A message computed at runtime did not compile against the localized initializer | Settings |
| `AttachmentRow` and `ItemRow` accept a bare trailing closure | The compiler called the call ambiguous | Chat |
| `SignUpForm` takes `isSubmitEnabled` | The brief asked for a submit button disabled until valid and the block could not do it | The fifth brief (onboarding) |

## The four apps

### Shop

Product list, product detail, cart, checkout.

| List | Detail | Cart | Checkout |
| --- | --- | --- | --- |
| ![Shop list](images/case-studies/shop-list.png) | ![Shop detail](images/case-studies/shop-detail.png) | ![Shop cart](images/case-studies/shop-cart.png) | ![Shop checkout](images/case-studies/shop-checkout.png) |

- Items installed: `avatar`, `badge`, `button`, `card`, `empty`, `field`, `input`, `item`, `metric-card`, `separator`.
- The agent wrote 367 lines. The installed items brought 1,264 lines it did not have to write.
- Friction at the end: one search for `quantity`, answered with the native `Stepper`.

### Chat

Conversation list, thread with a date marker, composer with an attachment row, and an empty conversation.

| Conversations | Thread | Composer | Empty |
| --- | --- | --- | --- |
| ![Chat conversations](images/case-studies/chat-conversations.png) | ![Chat thread](images/case-studies/chat-thread.png) | ![Chat composer](images/case-studies/chat-composer.png) | ![Chat empty](images/case-studies/chat-empty.png) |

- Items installed: `attachment`, `avatar`, `badge`, `bubble`, `button`, `empty`, `input`, `item`, `marker`, `message`, `message-scroller`, `progress`, `separator`.
- The agent wrote 308 lines. The installed items brought 1,812 lines.
- Friction at the end: none. Before the changes, this app cost the most in plain SwiftUI, because bubbles, message rows, and the date marker were all written by hand.

### Settings

Profile header, notification toggles with a digest picker, an account form with validation, and a sign out confirmation.

| Profile | Notifications | Account | Sign out |
| --- | --- | --- | --- |
| ![Settings profile](images/case-studies/settings-profile.png) | ![Settings notifications](images/case-studies/settings-notifications.png) | ![Settings account](images/case-studies/settings-account.png) | ![Settings sign out](images/case-studies/settings-signout.png) |

- Items installed: `avatar`, `badge`, `button`, `field`, `input`, `item`, `select`, `separator`, `settings-section`.
- The agent wrote 309 lines. The installed items brought 1,317 lines.
- Friction at the end: none.

### Finance

Three metric cards over a bar chart, a transaction list that shows skeletons first, a filter accordion, and a refresh button with a toast.

| Overview | Transactions | Filters | Refresh |
| --- | --- | --- | --- |
| ![Finance overview](images/case-studies/finance-overview.png) | ![Finance transactions](images/case-studies/finance-transactions.png) | ![Finance filters](images/case-studies/finance-filters.png) | ![Finance refresh](images/case-studies/finance-refresh.png) |

- Items installed: `accordion`, `button`, `chart`, `checkbox`, `metric-card`, `separator`, `skeleton`, `toast`, `transaction-row`.
- The agent wrote 350 lines. The installed items brought 1,479 lines.
- Friction at the end: none. The transactions screenshot shows the skeleton state the brief asked for during the first 1.5 seconds.

## What we took from it

- An agent with the registry does not rebuild components. That held in every run, judged twice, once by an agent and once by a classifier.
- Names matter more than documentation length. Most of the friction was a word the developer says and the catalog did not answer to. Search words fixed it.
- The remaining friction was API shape: a type that did not accept a runtime value, an initializer the compiler could not pick, a block missing one flag. Each fix was a few lines.
- A fifth brief, onboarding with sign in, sign up, a questionnaire, and a one time code, was added late in the study. It runs the same way and is not shown here.
