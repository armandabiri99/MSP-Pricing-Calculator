# MSP Pricing Calculator

A lightweight SwiftUI iOS application that lets Managed‑Service Providers (MSPs) generate quick, editable quotes for their clients. Device counts, add‑on services, and unit pricing are kept in a simple JSON file so you can update prices or introduce new services without recompiling the app.

---

## ✨ Features

* **Instant quote builder** – steppers and toggles show a live‑updating total.
* **JSON‑driven pricing** – all rates and service names live in `pricing.json`.
* **MVVM architecture** – clearly separated *Models*, *ViewModels*, *Views*.
* **SwiftUI previews** – tweak UI in real time with `#Preview` providers.
* **iCloud‑ready** – point the JSON loader to a remote URL to update prices over‑the‑air.
* **Branded PDF quotes** – include your logo, company and customer names in an exported PDF.
* **Editable pricing** – adjust unit costs in the new Settings tab.

---

## 🚀 Getting Started

### Prerequisites

| Tool           | Version |
| -------------- | ------- |
| Xcode          | 16.0 +  |
| iOS Deployment | 18.5 +  |

### Clone & Run

```bash
# clone the repo (or your fork)
$ git clone https://github.com/armandabiri99/MSP‑Pricing‑Calculator.git
$ cd msp‑pricing‑calculator

# open in Xcode
$ open MSP\ Pricing\ Calculator.xcodeproj
```

1. Select an **iPhone simulator** (e.g. *iPhone 16 Pro*).
2. Press **⌘R**. The quote form appears with default pricing.
3. In the **MSP** section of the form, enter your company name and upload a logo.
4. In the **Customer** section, provide the client's name.
5. Use the **Settings** tab to tweak pricing as needed.
6. Tap **Download Quote** to create a PDF branded with this information.

---

## 🗄 How Pricing Works

`pricing.json` lives in **Resources ➜ pricing.json** and looks like this:

```json
{
  "services": [
    { "code": "base_server",  "name": "Server Support",           "unitPrice": 100 },
    { "code": "base_ws",      "name": "Workstation Support",      "unitPrice": 25  },
    { "code": "bkup_server",  "name": "Server Cloud Backup",       "unitPrice": 55  },
    { "code": "bkup_ws",      "name": "Workstation Cloud Backup",  "unitPrice": 16  },
    { "code": "email_sec",    "name": "Advanced Email Security",   "unitPrice": 8   },
    { "code": "huntress",    "name": "Huntress Cybersecurity",      "unitPrice": 6   },
    { "code": "webroot",     "name": "Webroot Cybersecurity",       "unitPrice": 4   },
    { "code": "nvr_8",       "name": "NVR 8-Port",                  "unitPrice": 250 },
    { "code": "nvr_16",      "name": "NVR 16-Port",                 "unitPrice": 350 },
    { "code": "nvr_32",      "name": "NVR 32-Port",                 "unitPrice": 550 },
    { "code": "nvr_64",      "name": "NVR 64-Port",                 "unitPrice": 750 },
    { "code": "camera",      "name": "Security Camera",             "unitPrice": 120 }
  ]
}
```

* **Add a new service** – append an object to `services`.
* **Change a price** – edit `unitPrice`.
* **No rebuild needed** if you copy the updated JSON into the app’s *Documents* folder or host it at a remote URL.
* Huntress and Webroot pricing applies to both servers and workstations.
* Prices can also be edited in-app from the Settings tab.

---

## 🏗 Architecture Overview

```
PricingApp
├── Models
│   ├── PricingConfig.swift    // JSON loader
│   └── Quote.swift            // stores user selections
├── ViewModels
│   └── QuoteViewModel.swift   // business logic + @Published props
└── Views
    ├── QuoteFormView.swift    // main screen
    ├── SettingsView.swift     // edit pricing
    └── SummaryView.swift      // (future) shareable PDF quote
```

---

## 🛣 Roadmap

* [ ] Persist quote history with Core Data
* [ ] Export quotes as branded PDF
* [ ] Remote JSON fetch + caching
* [ ] Dark‑mode tuned color palette

---

## 🤝 Contributing

1. **Fork** the repo.
2. Create your feature branch:

   ```bash
   git checkout -b feature/my‑awesome‑feature
   ```
3. Commit your changes:

   ```bash
   git commit -m "Add awesome feature"
   ```
4. Push to the branch:

   ```bash
   git push origin feature/my‑awesome‑feature
   ```
5. Open a **Pull Request**.

---

## 📄 License

This project is licensed under the MIT License – see the [LICENSE] file for details.
