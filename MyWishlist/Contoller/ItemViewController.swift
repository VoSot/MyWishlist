import UIKit
import RealmSwift

class ItemViewController: UITableViewController {

    let realm = try! Realm()
    var wishItems: Results<WishItem>?

    var selectedCategory: WishCategory? {
        didSet {
            loadItems()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
    }

    private func configureNavigationBar() {
        guard let navBar = navigationController?.navigationBar else {
            return
        }
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.systemTeal
        appearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navBar.standardAppearance = appearance
        navBar.scrollEdgeAppearance = navBar.standardAppearance
    }

    // MARK: - Tableview Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return wishItems?.count ?? 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        content.text = wishItems?[indexPath.row].title ?? "No Items Added yet"
        cell.contentConfiguration = content
        return cell
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete, let item = wishItems?[indexPath.row] {
            do {
                try realm.write {
                    realm.delete(item)
                    tableView.deleteRows(at: [indexPath], with: .automatic)
                }
            } catch {
                print("Error deleting item, \(error)")
            }
        }
    }

    // MARK: - TableView Delegate Methods

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let item = wishItems?[indexPath.row], let url = URL(string: item.link) {
            UIApplication.shared.open(url)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }

    // MARK: - Add new items

    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        presentAddNewItemAlert()
    }

    private func presentAddNewItemAlert() {
        var titleField = UITextField()
        var linkField = UITextField()

        let alert = UIAlertController(title: "Add New Item", message: "", preferredStyle: .alert)
        let label = createErrorLabel(for: alert.view)

        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Item"
            alertTextField.returnKeyType = .next
            titleField = alertTextField
        }

        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Add a link"
            linkField = alertTextField
        }

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Done", style: .default, handler: { action in
            self.handleAddItem(titleField: titleField, linkField: linkField, alert: alert, label: label)
        }))

        present(alert, animated: true, completion: nil)
    }

    private func createErrorLabel(for alertView: UIView) -> UILabel {
        let label = UILabel(frame: CGRect(x: 0, y: 40, width: 270, height: 18))
        label.textAlignment = .center
        label.textColor = .red
        label.font = label.font.withSize(11)
        alertView.addSubview(label)
        label.isHidden = true
        return label
    }

    private func handleAddItem(titleField: UITextField, linkField: UITextField, alert: UIAlertController, label: UILabel) {
        guard let currentCategory = selectedCategory else { return }

        guard let title = titleField.text, !title.isEmpty else {
            showError(label: label, message: "Please enter an item", in: alert)
            return
        }

        guard let link = linkField.text, !link.isEmpty else {
            showError(label: label, message: "Please enter a link", in: alert)
            return
        }

        guard canOpenURL(url: link) else {
            showError(label: label, message: "Enter a valid link, e.g., https://www.google.com/", in: alert)
            return
        }

        do {
            try realm.write {
                let newItem = WishItem()
                newItem.title = title
                newItem.link = link
                currentCategory.items.append(newItem)
            }
            tableView.reloadData()
        } catch {
            print("Error saving new items, \(error)")
        }
    }

    private func showError(label: UILabel, message: String, in alert: UIAlertController) {
        label.text = message
        label.isHidden = false
        present(alert, animated: true, completion: nil)
    }

    private func canOpenURL(url: String?) -> Bool {
        guard let urlString = url, let url = URL(string: urlString) else {
            return false
        }
        return ["http", "https", "ftp"].contains(url.scheme)
    }

    // MARK: - Read from Realm Database

    func loadItems() {
        wishItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        tableView.reloadData()
    }
}

extension ItemViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        wishItems = selectedCategory?.items.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "title", ascending: true)
        tableView.reloadData()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            loadItems()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        } else {
            searchBarSearchButtonClicked(searchBar)
        }
    }
}
