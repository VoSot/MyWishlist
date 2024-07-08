import UIKit
import RealmSwift

class CategoryViewController: UITableViewController {
    
    private let realm = try! Realm()
    private var categoryList: Results<WishCategory>?

    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        loadCategories()
    }

    private func configureNavigationBar() {
        guard let navBar = navigationController?.navigationBar else { return }
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.systemTeal
        appearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navBar.standardAppearance = appearance
        navBar.scrollEdgeAppearance = navBar.standardAppearance
    }

    // MARK: - Tableview Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryList?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        content.text = categoryList?[indexPath.row].name ?? "No Categories Added yet"
        cell.contentConfiguration = content
        return cell
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            presentDeleteConfirmationAlert(at: indexPath)
        }
    }

    private func presentDeleteConfirmationAlert(at indexPath: IndexPath) {
        let alert = UIAlertController(title: "Delete the Category?", message: "All items will be deleted", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self] _ in
            self?.deleteCategory(at: indexPath)
        }))
        present(alert, animated: true, completion: nil)
    }

    private func deleteCategory(at indexPath: IndexPath) {
        if let category = categoryList?[indexPath.row] {
            do {
                try realm.write {
                    realm.delete(category.items)
                    realm.delete(category)
                }
                tableView.deleteRows(at: [indexPath], with: .automatic)
            } catch {
                print("Error deleting category, \(error)")
            }
        }
    }

    // MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToItems" {
            if let destinationVC = segue.destination as? ItemViewController, let indexPath = tableView.indexPathForSelectedRow {
                destinationVC.selectedCategory = categoryList?[indexPath.row]
            }
        }
    }

    // MARK: - Add new categories

    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        presentAddCategoryAlert()
    }

    private func presentAddCategoryAlert() {
        var nameField = UITextField()
        
        let alert = UIAlertController(title: "Add a category", message: "", preferredStyle: .alert)
        let label = createErrorLabel(for: alert.view)

        alert.addTextField { textfield in
            textfield.placeholder = "Category"
            nameField = textfield
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Done", style: .default, handler: { [weak self] _ in
            self?.addCategory(nameField: nameField, label: label, alert: alert)
        }))
        
        present(alert, animated: true, completion: nil)
    }

    private func createErrorLabel(for alertView: UIView) -> UILabel {
        let label = UILabel(frame: CGRect(x: 0, y: 40, width: 270, height: 18))
        label.textAlignment = .center
        label.textColor = .red
        label.font = label.font.withSize(12)
        alertView.addSubview(label)
        label.isHidden = true
        return label
    }

    private func addCategory(nameField: UITextField, label: UILabel, alert: UIAlertController) {
        guard let name = nameField.text, !name.isEmpty else {
            showError(label: label, message: "Please enter a category", in: alert)
            return
        }

        do {
            try realm.write {
                let newCategory = WishCategory()
                newCategory.name = name
                realm.add(newCategory)
            }
            tableView.reloadData()
        } catch {
            print("Error saving categories, \(error)")
        }
    }

    private func showError(label: UILabel, message: String, in alert: UIAlertController) {
        label.text = message
        label.isHidden = false
        present(alert, animated: true, completion: nil)
    }

    // MARK: - Read from Realm Database
        
    private func loadCategories() {
        categoryList = realm.objects(WishCategory.self)
        tableView.reloadData()
    }
}
