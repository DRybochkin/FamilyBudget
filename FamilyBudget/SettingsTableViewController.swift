//
//  SettingsTableViewController.swift
//  FamilyBudget
//
//  Created by Dmitry Rybochkin on 27.01.17.
//  Copyright © 2017 Dmitry Rybochkin. All rights reserved.
//

import UIKit

class SettingsTableViewController: BaseTableViewController {
    @IBOutlet weak var keywordTextField: UITextField!
    @IBOutlet weak var nicknameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

    @IBOutlet weak var loadBarButton: UIBarButtonItem!
    @IBOutlet weak var saveBarButton: UIBarButtonItem!
    @IBOutlet weak var clearBarButton: UIBarButtonItem!

    var user: DOUser!

    var isLoading: Bool = true {
        didSet {
            if (passwordTextField != nil) {
                passwordTextField.isEnabled = isLoading
            }
            if (keywordTextField != nil) {
                keywordTextField.isEnabled = isLoading
            }
            if (nicknameTextField != nil) {
                nicknameTextField.isEnabled = isLoading
            }
            if (loadBarButton != nil) {
                loadBarButton.isEnabled = isLoading
            }
            if (clearBarButton != nil) {
                clearBarButton.isEnabled = isLoading
            }
        }
    }

    @IBAction func onLoad(_ sender: Any) {
        let alertController = UIAlertController(title: "Выбор действия", message: "Чего изволите?", preferredStyle: UIAlertControllerStyle.alert)

        if (SQLiteDataStore.sharedInstance.currentUser.isConnected) {
            alertController.addAction(UIAlertAction(title: "Load data from server", style: .default, handler: { (_:UIAlertAction!) -> Void in
                NotificationCenter.default.post(name: Notification.Name.FamilyBudgetDidChangeOptions, object: ["AppOptions", "change", self.user])
            }))
        }
        alertController.addAction(UIAlertAction(title: "Create default categories", style: .destructive, handler: { (_:UIAlertAction!) -> Void in
            _ = SQLiteDataStore.sharedInstance.createDefaultCategories(needPost: true)
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        present(alertController, animated: true, completion: nil)
    }

    @IBAction func onClear(_ sender: Any) {
        let alertController = UIAlertController(title: "Подтверждение", message: "", preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_:UIAlertAction!) -> Void in
            _ = DOTransactionDataHelper.clear(needPost: true)
            _ = DOCategoryDataHelper.clear(needPost: true)
            _ = DOUserDataHelper.deleteOther(needPost: true)
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        if (SQLiteDataStore.sharedInstance.currentUser.isConnected) {
            alertController.message = "Очистить все локальные данные? При необходимости вы сможете загрузить их с сервера."
        } else {
            alertController.message = "Данные будут удалены безвозвратно. Очистить данные?"
        }

        present(alertController, animated: true, completion: nil)
    }

    @IBAction func onSave(_ sender: Any) {
        let password = passwordTextField.text!.trimmingCharacters(in: CharacterSet(charactersIn: " "))
        let keyword = keywordTextField.text!

        var needNetworkChange = false
        let alertController = UIAlertController(title: "Подтверждение", message: "", preferredStyle: UIAlertControllerStyle.alert)
        if (user.userPassword != password) {
            if (user.userPassword == "") {
                //подключаемся к серверу
                alertController.message = "Ваши данные будут синхронизироваться с севером.\n\n"
                needNetworkChange = true
            } else {
                if (password == "") {
                    //отключаемся от сервера
                    alertController.message = "Ваши данные больше не будут синхронизироваться с севером.\n\n"
                } else {
                    //меняем пароль
                    alertController.message = "Ваш пароль будет изменен.\n\n"
                    needNetworkChange = true
                }
            }
        } else if (password != "") {
            needNetworkChange = true
        }

        if (user.userGroupKeyword != keyword && needNetworkChange) {
            if (user.userGroupKeyword == "") {
                //вступаем в семью
                alertController.message = alertController.message! + "Ваши подключитесь к семье и все ее участники увидят ваши данные.\n\n"
            } else {
                if (keyword == "") {
                    //выходим из семьи
                    alertController.message = alertController.message! + "Вы покинете текущую семью и все данные членов семьи, исключая ваши, будут удалены.\n\n"
                } else {
                    //меняем семью
                    alertController.message = alertController.message! + "Вы меняете семью. Все данные предыдущей семьи, исключая ваши, будут удалены. Данные новой семьи будут загружены, а все ее участники увидят ваши данные.\n\n"
                }
            }
        }

        if (alertController.message != "") {
            alertController.message = alertController.message! + "Продолжить?"
        } else {
            alertController.message = "Изменить данные?"
        }

        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_: UIAlertAction!) -> Void in
            if (self.user.userGroupKeyword != keyword && needNetworkChange) {
                _ = DOTransactionDataHelper.deleteOther(needPost: false)
                _ = DOCategoryDataHelper.deleteOther(needPost: false)
                _ = DOUserDataHelper.deleteOther(needPost: false)
            }

            self.user.userGroupKeyword = self.keywordTextField.text!
            self.user.userTitle = self.nicknameTextField.text!
            self.user.userPassword = self.passwordTextField.text!

            let resolvedUser = DOUserDataHelper.resolve(item: self.user, needPost: false)
            if (resolvedUser != nil) {
                SQLiteDataStore.sharedInstance.currentUser = resolvedUser!
            }

            if (needNetworkChange) {
                //Синхронизироваться с сервером и обновить локальные данные
                NotificationCenter.default.post(name: Notification.Name.FamilyBudgetDidChangeOptions, object: ["AppOptions", "change", self.user])
            }
            self.onChange(nil)
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }

    @IBAction func onChange(_ sender: UITextField?) {
        let password = passwordTextField.text!.trimmingCharacters(in: CharacterSet(charactersIn: " "))
        let keyword = keywordTextField.text!
        let nickname = nicknameTextField.text!

        saveBarButton.isEnabled = (password != user.userPassword || nickname != user.userTitle || keyword != user.userGroupKeyword)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        saveBarButton.isEnabled = false

        loadData()

        NotificationCenter.default.addObserver(self, selector: #selector(loadData), name: NSNotification.Name.FamilyBudgetCurrentUserChanged, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func reloadData() {

    }

    override func loadData() {
        user = SQLiteDataStore.sharedInstance.currentUser.deepCopy()

        keywordTextField.text = user.userGroupKeyword
        nicknameTextField.text = user.userTitle
        passwordTextField.text = user.userPassword
    }

    override func showIndicator(_ notification: Notification) {
        if (isLoading) {
            isLoading = false
        }
        super.showIndicator(notification)
    }

    override func hideIndicator() {
        super.hideIndicator()
        isLoading = true
    }
}
