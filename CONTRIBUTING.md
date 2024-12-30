## **1. Introduction**

Thank you for considering contributing to the **DELPHY COSMOS Deployment Repository**. This document outlines guidelines to ensure consistency, quality, and transparency for all contributions. Whether you're fixing bugs, adding new features, or improving documentation, please follow these guidelines.

---

## **2. Code of Conduct**

By contributing to this project, you agree to follow our **Code of Conduct**, which promotes a respectful and inclusive environment for all developers and users.

- Be kind and respectful in all communications.
- Provide constructive feedback during reviews.
- Assume positive intent from other contributors.

---

## **3. Getting Started**

### **3.1 Prerequisites**

Ensure you have the following installed:

- **Ruby 2.7.x**
- **Bundler 1.17.3**
- **COSMOS v4**
- **Git**

Install dependencies:

```bash
gem install bundler -v 1.17.3
bundle _1.17.3_ install
```

Validate the environment:

```bash
ruby -v
bundler -v
bundle exec rspec
```

---

### **3.2 Fork the Repository**

1. Navigate to the [repository on GitHub](https://github.com/guygrubbs/cosmos_delphy).
2. Click **Fork** to create your copy of the repository.
3. Clone the repository to your local machine:

```bash
git clone https://github.com/your-username/cosmos_delphy.git
cd cosmos_delphy
```

4. Set the upstream repository:

```bash
git remote add upstream https://github.com/guygrubbs/cosmos_delphy.git
```

---

### **3.3 Create a Feature Branch**

Use a descriptive branch name for your feature or fix:

```bash
git checkout -b feature/your-feature-name
```

**Examples:**
- `feature/telemetry-validation`
- `fix/connection-timeout`
- `docs/update-readme`

---

## **4. Making Changes**

### **4.1 Follow Code Standards**

- Adhere to the **Ruby Style Guide** and use `rubocop` to lint your code:

```bash
bundle exec rubocop
```

- Write clean, maintainable code with descriptive comments.

### **4.2 Write Unit and Integration Tests**

- Add or update unit tests in:
  ```
  tests/targets/DELPHY/
  ```
- Validate your changes with RSpec:

```bash
bundle exec rspec
```

---

### **4.3 Commit Your Changes**

Write clear and concise commit messages following the format:

```plaintext
<type>: <short description>

<detailed description>
```

**Example:**
```
fix: Correct telemetry timeout handling

Updated telemetry timeout validation logic to prevent connection failures.
```

**Commit Types:**
- `feat`: Add a new feature.
- `fix`: Fix a bug.
- `docs`: Documentation updates.
- `test`: Add or update tests.
- `refactor`: Code refactoring without changing functionality.

Add your changes:

```bash
git add .
git commit -m "feat: add telemetry validation"
```

---

### **4.4 Push Changes**

Push your feature branch to your forked repository:

```bash
git push origin feature/your-feature-name
```

---

## **5. Submit a Pull Request (PR)**

1. Go to your fork on GitHub.
2. Click **New Pull Request**.
3. Select your branch and compare it with the `main` branch of the upstream repository.
4. Fill out the PR template with:
   - **Description of Changes**
   - **Testing Details**
   - **Related Issues**
5. Submit the pull request.

**Before Submitting:**
- Ensure all tests pass (`bundle exec rspec`).
- Validate logs in:
  ```
  config/targets/DELPHY/tools/logs/
  ```
- Ensure no linting errors (`bundle exec rubocop`).

---

## **6. Review Process**

1. Your PR will be reviewed by at least one maintainer.
2. Address feedback promptly.
3. Ensure tests pass before requesting a re-review.

---

## **7. Testing Requirements**

Before merging, ensure:

- ✅ All **unit tests** (`rspec`) pass.
- ✅ All **integration tests** run successfully.
- ✅ No **critical errors** in logs.
- ✅ Code adheres to **Ruby Style Guide** (`rubocop`).

Run the full test suite:

```bash
bundle exec rspec
bundle exec rubocop
```

---

## **8. Best Practices**

- Keep your PR small and focused on a single feature or fix.
- Document changes in the `README.md` if applicable.
- Avoid hardcoding values; use environment variables (`dotenv`) where possible.
- Always include meaningful log messages.

---

## **9. Merging Criteria**

- ✅ Approved by at least one maintainer.
- ✅ CI/CD pipeline passes all checks.
- ✅ Tests cover the new functionality or fix.
- ✅ Changes are documented appropriately.

---

## **10. Reporting Issues**

If you encounter a bug or have a feature request, please:

1. Check the [open issues](https://github.com/guygrubbs/cosmos_delphy/issues) to see if it’s already reported.
2. If not, create a **New Issue** with:
   - A clear title.
   - Steps to reproduce.
   - Expected behavior.
   - Logs or screenshots (if applicable).

---

## **11. Local Environment Cleanup**

When you're done, clean up your feature branch:

```bash
git checkout main
git pull upstream main
git branch -d feature/your-feature-name
```

---

## **12. Contact and Support**

For further assistance, contact:

- **Maintainer:** [guygrubbs@gmail.com](mailto:guygrubbs@gmail.com)  
- **Operations Team:** [kolton.dieckow@swri.org](mailto:kolton.dieckow@swri.org)  

---

## **13. Final Note**

Thank you for your contribution to the DELPHY COSMOS Deployment Repository! Every contribution, no matter how small, helps improve the project.

---