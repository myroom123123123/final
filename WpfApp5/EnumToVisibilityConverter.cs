using System;
using System.Globalization;
using System.Windows;
using System.Windows.Data;

namespace WpfApp5
{
    public class EnumToVisibilityConverter : IValueConverter
    {
        public object Convert(object value, Type targetType, object parameter, CultureInfo culture)
        {
            if (value == null || parameter == null)
                return Visibility.Collapsed;

            // Отримуємо строкове представлення enum-значення
            string valueStr = value.ToString();
            string parameterStr = parameter.ToString();

            // Перевіряємо, чи співпадають значення
            bool areEqual = string.Equals(valueStr, parameterStr, StringComparison.OrdinalIgnoreCase);
            
            // Якщо співпадають - Visible, інакше - Collapsed
            return areEqual ? Visibility.Visible : Visibility.Collapsed;
        }

        public object ConvertBack(object value, Type targetType, object parameter, CultureInfo culture)
        {
            // Зворотнє перетворення не потрібне
            throw new NotImplementedException();
        }
    }
}