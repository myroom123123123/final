using System;
using System.Globalization;
using System.Windows;
using System.Windows.Data;

namespace WpfApp5.Converters
{
    public partial class InverseBooleanToVisibilityConverter : IValueConverter
    {
        object IValueConverter.Convert(object value, Type targetType, object parameter, CultureInfo culture)
        {
            if (value == null) throw new ArgumentNullException(nameof(value));
            if (value is bool boolValue)
            {
                // Інвертуємо булеве значення: якщо false - показуємо, якщо true - ховаємо
                return boolValue ? Visibility.Collapsed : Visibility.Visible;
            }
            
            return Visibility.Collapsed;
        }

        object IValueConverter.ConvertBack(object value, Type targetType, object parameter, CultureInfo culture)
        {
            if (value is Visibility visibility)
            {
                // Зворотнє перетворення: Visible -> false, Collapsed -> true
                return visibility != Visibility.Visible;
            }
            
            return true;
        }
    }
}