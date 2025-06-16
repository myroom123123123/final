using System;
using System.Globalization;
using System.Windows.Data;
using System.Windows.Media.Imaging;

namespace WpfApp5.Converters
{
    public class UrlToImageConverter : IValueConverter
    {
        public object Convert(object value, Type targetType, object parameter, CultureInfo culture)
        {
            string url = value as string;
            
            // Якщо URL порожній або null, повертаємо заглушку
            if (string.IsNullOrEmpty(url))
            {
                url = "https://i.pravatar.cc/100";
            }
            
            try
            {
                BitmapImage image = new BitmapImage();
                image.BeginInit();
                image.UriSource = new Uri(url, UriKind.RelativeOrAbsolute);
                image.CacheOption = BitmapCacheOption.OnLoad; // Кешуємо зображення
                image.EndInit();
                return image;
            }
            catch (Exception)
            {
                // У випадку помилки, повертаємо заглушку
                BitmapImage fallbackImage = new BitmapImage();
                fallbackImage.BeginInit();
                fallbackImage.UriSource = new Uri("https://i.pravatar.cc/100", UriKind.Absolute);
                fallbackImage.CacheOption = BitmapCacheOption.OnLoad;
                fallbackImage.EndInit();
                return fallbackImage;
            }
        }

        public object ConvertBack(object value, Type targetType, object parameter, CultureInfo culture)
        {
            throw new NotImplementedException();
        }
    }
}