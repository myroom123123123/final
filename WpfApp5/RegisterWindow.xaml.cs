using System;
using System.Text.RegularExpressions;
using System.Windows;
using MahApps.Metro.Controls;
using WpfApp5.Models;
using WpfApp5.Services;
using WpfApp5.ViewModels;

namespace WpfApp5
{
    public partial class RegisterWindow : MetroWindow
    {
        private readonly UserService _userService;
        public string RegisteredEmail { get; private set; }
        
        public RegisterWindow()
        {
            InitializeComponent();
            
            // Инициализируем сервисы
            var app = Application.Current as App;
            if (app != null)
            {
                _userService = app.ServiceProvider.GetService(typeof(UserService)) as UserService;
            }
            
            // Устанавливаем значение по умолчанию для ComboBox
            RoleComboBox.SelectedIndex = 0;
            
            // Привязываем обработчики изменения полей
            RoleComboBox.SelectionChanged += RoleComboBox_SelectionChanged;
            EmailTextBox.TextChanged += EmailTextBox_TextChanged;
            PasswordBox.PasswordChanged += PasswordBox_PasswordChanged;
            ConfirmPasswordBox.PasswordChanged += ConfirmPasswordBox_PasswordChanged;
            
            // Инициализируем видимость полей в зависимости от выбранной роли
            UpdateFieldsVisibility();
        }
        
        private void RoleComboBox_SelectionChanged(object sender, System.Windows.Controls.SelectionChangedEventArgs e)
        {
            UpdateFieldsVisibility();
        }
        
        private void UpdateFieldsVisibility()
        {
            var selectedItem = RoleComboBox.SelectedItem as System.Windows.Controls.ComboBoxItem;
            
            if (selectedItem != null)
            {
                var role = selectedItem.Tag.ToString();
                
                if (role == "Student")
                {
                    GroupTextBox.IsEnabled = true;
                    DepartmentTextBox.IsEnabled = false;
                    DepartmentTextBox.Text = string.Empty;
                }
                else if (role == "Teacher")
                {
                    GroupTextBox.IsEnabled = false;
                    DepartmentTextBox.IsEnabled = true;
                    GroupTextBox.Text = string.Empty;
                }
            }
        }
        
        private void EmailTextBox_TextChanged(object sender, System.Windows.Controls.TextChangedEventArgs e)
        {
            ValidateEmail();
        }
        
        private void PasswordBox_PasswordChanged(object sender, RoutedEventArgs e)
        {
            ValidatePassword();
        }
        
        private void ConfirmPasswordBox_PasswordChanged(object sender, RoutedEventArgs e)
        {
            ValidateConfirmPassword();
        }
        
        private bool ValidateEmail()
        {
            var email = EmailTextBox.Text.Trim();
            
            if (string.IsNullOrWhiteSpace(email))
            {
                EmailErrorTextBlock.Text = "Введите Email";
                return false;
            }
            
            // Проверка формата email
            var regex = new Regex(@"^[^@\s]+@[^@\s]+\.[^@\s]+$");
            if (!regex.IsMatch(email))
            {
                EmailErrorTextBlock.Text = "Некорректный формат Email";
                return false;
            }
            
            EmailErrorTextBlock.Text = string.Empty;
            return true;
        }
        
        private bool ValidatePassword()
        {
            var password = PasswordBox.Password;
            
            if (string.IsNullOrWhiteSpace(password))
            {
                PasswordErrorTextBlock.Text = "Введите пароль";
                return false;
            }
            
            if (password.Length < 6)
            {
                PasswordErrorTextBlock.Text = "Пароль должен содержать минимум 6 символов";
                return false;
            }
            
            PasswordErrorTextBlock.Text = string.Empty;
            return true;
        }
        
        private bool ValidateConfirmPassword()
        {
            var password = PasswordBox.Password;
            var confirmPassword = ConfirmPasswordBox.Password;
            
            if (string.IsNullOrWhiteSpace(confirmPassword))
            {
                ConfirmPasswordErrorTextBlock.Text = "Подтвердите пароль";
                return false;
            }
            
            if (password != confirmPassword)
            {
                ConfirmPasswordErrorTextBlock.Text = "Пароли не совпадают";
                return false;
            }
            
            ConfirmPasswordErrorTextBlock.Text = string.Empty;
            return true;
        }
        
        private bool ValidateFullName()
        {
            var fullName = FullNameTextBox.Text.Trim();
            
            if (string.IsNullOrWhiteSpace(fullName))
            {
                FullNameErrorTextBlock.Text = "Введите ФИО";
                return false;
            }
            
            FullNameErrorTextBlock.Text = string.Empty;
            return true;
        }
        
        private bool ValidateGroup()
        {
            var selectedItem = RoleComboBox.SelectedItem as System.Windows.Controls.ComboBoxItem;
            
            if (selectedItem != null && selectedItem.Tag.ToString() == "Student")
            {
                var group = GroupTextBox.Text.Trim();
                
                if (string.IsNullOrWhiteSpace(group))
                {
                    GroupErrorTextBlock.Text = "Введите группу";
                    return false;
                }
            }
            
            GroupErrorTextBlock.Text = string.Empty;
            return true;
        }
        
        private bool ValidateDepartment()
        {
            var selectedItem = RoleComboBox.SelectedItem as System.Windows.Controls.ComboBoxItem;
            
            if (selectedItem != null && selectedItem.Tag.ToString() == "Teacher")
            {
                var department = DepartmentTextBox.Text.Trim();
                
                if (string.IsNullOrWhiteSpace(department))
                {
                    DepartmentErrorTextBlock.Text = "Введите кафедру";
                    return false;
                }
            }
            
            DepartmentErrorTextBlock.Text = string.Empty;
            return true;
        }
        
        private async void RegisterButton_Click(object sender, RoutedEventArgs e)
        {
            // Очищаем общее сообщение об ошибке
            ErrorMessageTextBlock.Text = string.Empty;
            
            // Валидация всех полей
            var isEmailValid = ValidateEmail();
            var isPasswordValid = ValidatePassword();
            var isConfirmPasswordValid = ValidateConfirmPassword();
            var isFullNameValid = ValidateFullName();
            var isGroupValid = ValidateGroup();
            var isDepartmentValid = ValidateDepartment();
            
            if (!isEmailValid || !isPasswordValid || !isConfirmPasswordValid || !isFullNameValid || !isGroupValid || !isDepartmentValid)
            {
                ErrorMessageTextBlock.Text = "Пожалуйста, исправьте ошибки в форме";
                return;
            }
            
            try
            {
                // Отключаем кнопки на время регистрации
                RegisterButton.IsEnabled = false;
                CancelButton.IsEnabled = false;
                
                // Получаем данные из формы
                var email = EmailTextBox.Text.Trim();
                var password = PasswordBox.Password;
                var fullName = FullNameTextBox.Text.Trim();
                
                var selectedItem = RoleComboBox.SelectedItem as System.Windows.Controls.ComboBoxItem;
                var roleString = selectedItem?.Tag.ToString() ?? "Student";
                
                var role = UserRole.Student;
                if (roleString == "Teacher")
                    role = UserRole.Teacher;
                
                var group = GroupTextBox.Text.Trim();
                var department = DepartmentTextBox.Text.Trim();
                
                // Регистрируем пользователя
                if (_userService != null)
                {
                    var newUser = await _userService.RegisterAsync(email, password, fullName, role);
                    
                    // Обновляем дополнительные данные пользователя
                    if (newUser != null)
                    {
                        if (role == UserRole.Student)
                            newUser.Group = group;
                        else if (role == UserRole.Teacher)
                            newUser.Department = department;
                        
                        await _userService.UpdateUserProfileAsync(newUser, newUser);
                        
                        // Сохраняем email для передачи в главное окно
                        RegisteredEmail = email;
                        
                        // Закрываем окно с успешным результатом
                        DialogResult = true;
                    }
                    else
                    {
                        ErrorMessageTextBlock.Text = "Не удалось создать пользователя. Возможно, email уже занят.";
                    }
                }
                else
                {
                    ErrorMessageTextBlock.Text = "Сервис пользователей недоступен";
                }
            }
            catch (Exception ex)
            {
                ErrorMessageTextBlock.Text = $"Ошибка при регистрации: {ex.Message}";
                Console.WriteLine($"Ошибка при регистрации: {ex.Message}");
                if (ex.InnerException != null)
                    Console.WriteLine($"Inner Exception: {ex.InnerException.Message}");
            }
            finally
            {
                // Включаем кнопки обратно
                RegisterButton.IsEnabled = true;
                CancelButton.IsEnabled = true;
            }
        }
        
        private void CancelButton_Click(object sender, RoutedEventArgs e)
        {
            // Закрываем окно с отрицательным результатом
            DialogResult = false;
        }
    }
}
