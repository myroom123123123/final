using System;
using System.Windows;
using Microsoft.Extensions.DependencyInjection;
using WpfApp5.Services;
using WpfApp5.ViewModels;
using WpfApp5.Views;
using WpfApp5.TestData;

namespace WpfApp5;

/// <summary>
/// Interaction logic for App.xaml
/// </summary>
public partial class App : Application
{
    private ServiceProvider _serviceProvider;

    public App()
    {
        var services = new ServiceCollection();
        ConfigureServices(services);
        _serviceProvider = services.BuildServiceProvider();
    }

    private void ConfigureServices(IServiceCollection services)
    {
        // Регистрация сервисов
        services.AddSingleton<SupabaseService>();
        services.AddSingleton<UserService>();
        services.AddSingleton<ScheduleService>();
        services.AddSingleton<MessageService>();
        services.AddSingleton<TestService>();
        
        // Регистрация ViewModel
        services.AddSingleton<MainViewModel>();
        
        // Регистрация окон
        services.AddTransient<MainWindow>();
    }

    protected override async void OnStartup(StartupEventArgs e)
    {
        base.OnStartup(e);
        
        try
        {
            // Ініціалізуємо сервіс Supabase
            var supabaseService = _serviceProvider.GetRequiredService<SupabaseService>();
            await supabaseService.Initialize();
            
            // Запускаємо головне вікно
            var mainWindow = _serviceProvider.GetRequiredService<MainWindow>();
            var mainViewModel = _serviceProvider.GetRequiredService<MainViewModel>();
            
            // Явно встановлюємо DataContext
            mainWindow.DataContext = mainViewModel;
            
            mainWindow.Show();
            
            // Ініціалізуємо стартові значення
            mainViewModel.StatusMessage = "Програма готова до роботи";
        }
        catch (Exception ex)
        {
            MessageBox.Show($"Помилка при запуску додатку: {ex.Message}", "Помилка", MessageBoxButton.OK, MessageBoxImage.Error);
            Current.Shutdown();
        }
    }
}
