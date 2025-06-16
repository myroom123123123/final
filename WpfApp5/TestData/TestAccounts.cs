// Тестові акаунти для освітньої платформи
// Для використання в розробці та тестуванні
using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using WpfApp5.Models;
using WpfApp5.Services;

namespace WpfApp5.TestData
{
    public static class TestAccounts
    {
        // Список тестових акаунтів для різних ролей
        public static List<(string Email, string Password, string FullName, UserRole Role)> TestUsers = new()
        {
            // Викладачі
            ("teacher1@test.edu", "Teacher123!", "Петров Іван Сергійович", UserRole.Teacher),
            ("teacher2@test.edu", "Teacher456!", "Коваленко Олена Миколаївна", UserRole.Teacher),
            ("teacher3@test.edu", "Teacher789!", "Бондаренко Михайло Петрович", UserRole.Teacher),
            
            // Студенти
            ("student1@test.edu", "Student123!", "Шевченко Анна Олександрівна", UserRole.Student),
            ("student2@test.edu", "Student456!", "Мельник Віктор Андрійович", UserRole.Student),
            ("student3@test.edu", "Student789!", "Ковальчук Марія Ігорівна", UserRole.Student),
            ("student4@test.edu", "Student101!", "Бойко Олег Вікторович", UserRole.Student),
            ("student5@test.edu", "Student202!", "Лисенко Софія Дмитрівна", UserRole.Student),
            
            // Адміністратор
            ("admin@test.edu", "Admin123!", "Адміністратор Системи", UserRole.Administrator)
        };
        
        /// <summary>
        /// Метод для заповнення бази даних тестовими користувачами
        /// </summary>
        public static async Task SeedTestUsers(UserService userService)
        {
            foreach (var user in TestUsers)
            {
                try
                {
                    // Перевіряємо, чи існує користувач з таким email
                    var existingUser = await userService.SupabaseService.GetUserByEmailAsync(user.Email);
                    
                    // Якщо користувач не існує, створюємо його
                    if (existingUser == null)
                    {
                        await userService.RegisterAsync(user.Email, user.Password, user.FullName, user.Role);
                        Console.WriteLine($"Створено акаунт: {user.FullName} ({user.Email})");
                    }
                    else
                    {
                        Console.WriteLine($"Акаунт вже існує: {user.Email}");
                    }
                }
                catch (Exception ex)
                {
                    Console.WriteLine($"Помилка при створенні акаунта {user.Email}: {ex.Message}");
                }
            }
        }
        
        /// <summary>
        /// Допоміжний метод для входу з тестовим акаунтом
        /// </summary>
        public static async Task<User?> LoginWithTestAccount(UserService userService, UserRole role)
        {
            var testUser = TestUsers.Find(u => u.Role == role);
            if (testUser == default)
                return null;
                
            return await userService.LoginAsync(testUser.Email, testUser.Password);
        }
    }
}