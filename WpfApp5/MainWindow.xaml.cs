using System;
using System.Windows;
using System.Windows.Controls;
using MahApps.Metro.Controls;
using WpfApp5.ViewModels;

namespace WpfApp5;

/// <summary>
/// Interaction logic for MainWindow.xaml
/// </summary>
public partial class MainWindow : MetroWindow
{
    public MainWindow()
    {
        InitializeComponent();

        // Слідкуємо за зміною DataContext, щоб завжди підписувати PasswordBox
        DataContextChanged += (s, e) =>
        {
            if (DataContext is MainViewModel viewModel)
            {
                // Відписуємося від старих подій, щоб уникнути витоків пам'яті
                PasswordBox.PasswordChanged -= OnPasswordChanged;
                
                // Підписуємося на нові події
                PasswordBox.PasswordChanged += OnPasswordChanged;
            }
        };

        // Якщо DataContext вже встановлено
        if (DataContext is MainViewModel viewModelInit)
        {
            PasswordBox.PasswordChanged += OnPasswordChanged;
        }
    }
    
    private void OnPasswordChanged(object sender, RoutedEventArgs e)
    {
        if (DataContext is MainViewModel viewModel && sender is PasswordBox passwordBox)
        {
            // Оновлюємо пароль у ViewModel
            viewModel.Password = passwordBox.Password;
        }
    }
    
    private async void LoginButton_Click(object sender, RoutedEventArgs e)
    {
        if (DataContext is MainViewModel viewModel)
        {
            // Встановлюємо пароль з PasswordBox
            viewModel.Password = PasswordBox.Password;
            
            try 
            {
                Console.WriteLine($"Спроба входу з email: {viewModel.Email}");
                
                // Скидаємо повідомлення про помилки
                viewModel.LoginErrorMessage = string.Empty;
                viewModel.EmailErrorMessage = string.Empty;
                viewModel.PasswordErrorMessage = string.Empty;
                
                // Валідація та спроба входу
                if (string.IsNullOrWhiteSpace(viewModel.Email))
                {
                    viewModel.EmailErrorMessage = "Будь ласка, введіть email";
                    viewModel.StatusMessage = "Введіть email та пароль";
                    Console.WriteLine("Помилка: Email не вказано");
                    return;
                }
                
                if (string.IsNullOrWhiteSpace(PasswordBox.Password))
                {
                    viewModel.PasswordErrorMessage = "Будь ласка, введіть пароль";
                    viewModel.StatusMessage = "Введіть email та пароль";
                    Console.WriteLine("Помилка: Пароль не вказано");
                    return;
                }
                
                viewModel.IsLoading = true;
                viewModel.StatusMessage = "Виконується вхід...";
                Console.WriteLine("Початок процесу входу...");
                
                // Замість окремого виклику сервісу використовуємо метод LoginAsync з ViewModel
                await viewModel.ManualLoginAsync();
            }
            catch (Exception ex)
            {
                viewModel.LoginErrorMessage = $"Помилка при вході: {ex.Message}";
                viewModel.StatusMessage = $"Помилка при вході: {ex.Message}";
                Console.WriteLine($"Помилка при вході: {ex.Message}");
                Console.WriteLine($"StackTrace: {ex.StackTrace}");
                if (ex.InnerException != null)
                    Console.WriteLine($"InnerException: {ex.InnerException.Message}");
            }
            finally
            {
                viewModel.IsLoading = false;
            }
        }
    }
}