using Fintech_Test_.ViewModel.Command;
using Fintech_Test_.Model;
using Fintech_Test_.Model.DataContext;
using Microsoft.EntityFrameworkCore;
using System.Collections.ObjectModel;
using System.Windows.Input;
using System.Windows;

namespace Fintech_Test_.ViewModel
{
    internal class ProductViewModel : ViewModelBase
    {
        #region Product

        private ObservableCollection<Product> _product;
        private string _name;
        private decimal _price;
        private Product _selectedProduct;

        public ObservableCollection<Product> Product
        {
            get => _product;
            set => Set(ref _product, value);
        }

        public string Name
        {
            get => _name;
            set => Set(ref _name, value);
        }

        public decimal Price
        {
            get => _price;
            set => Set(ref _price, value);
        }

        public Product? SelectedProduct
        {
            get { return _selectedProduct; }
            set { Set(ref _selectedProduct, value); }
        }


        public async Task LoadProductDataAsync()
        {
            try
            {
                using (var context = new ApplicationContext())
                {
                    Product = new ObservableCollection<Product>(await context.Product.ToListAsync());
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show($"An error occurred: {ex.Message}", "Error", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }



        #region Добавить Product        

        public ICommand AddProductCommand { get; }
        private bool CanAddProductCommandExecute(object parameter) => true;
        private async void OnAddProductCommandExecuted(object parameter)
        {
            await AddProductAsync();
        }

        private async Task AddProductAsync()
        {
            try
            {
                using (var context = new ApplicationContext())
                {
                    var newProduct = new Product
                    {
                        Name = Name,
                        Price = Price
                    };

                    context.Product.Add(newProduct);
                    await context.SaveChangesAsync();
                    Product.Add(newProduct);

                    Name = string.Empty;
                    Price = 0.0m;
                    await LoadProductDataAsync();
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show($"An error occurred: {ex.Message}", "Error", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        #endregion



        #region Изменить Product

        public ICommand UpdateProductCommand { get; }
        private bool CanUpdateProductCommandExecute(object parameter) => SelectedProduct != null ? true : false;

        private async void OnUpdateProductCommandExecuted(object parameter)
        {
            await UpdateProductAsync();
        }
        private async Task UpdateProductAsync()
        {
            try
            {
                using (var context = new ApplicationContext())
                {
                    if (SelectedProduct != null)
                    {
                        Name = SelectedProduct.Name;
                        Price = SelectedProduct.Price;

                        context.Product.Update(SelectedProduct);
                        await context.SaveChangesAsync();

                        Name = string.Empty;
                        Price = 0.0m;
                        await LoadProductDataAsync();
                    }
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show($"An error occurred: {ex.Message}", "Error", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        #endregion



        #region Удалить Product

        public ICommand DeleteProductCommand { get; }
        private bool CanDeleteProductCommandExecute(object parameter) => SelectedProduct != null ? true : false;
        private async void OnDeleteProductCommandExecuted(object parameter)
        {
            await DeleteProductAsync();
        }
        private async Task DeleteProductAsync()
        {
            try
            {
                using (var context = new ApplicationContext())
                {
                    if (SelectedProduct != null)
                    {
                        context.Product.Remove(SelectedProduct);
                        await context.SaveChangesAsync();

                        SelectedProduct = null;
                        await LoadProductDataAsync();
                    }
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show($"An error occurred: {ex.Message}", "Error", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        #endregion

        #endregion


        #region Визульные улучшения Expanders
        private bool _expander1IsExpanded;
        private bool _expander2IsExpanded;
        public bool Expander1IsExpanded
        {
            get { return _expander1IsExpanded; }
            set
            {
                Set(ref _expander1IsExpanded, value);
                if (value)
                {
                    Expander2IsExpanded = false;
                }
            }
        }

        public bool Expander2IsExpanded
        {
            get { return _expander2IsExpanded; }
            set
            {
                Set(ref _expander2IsExpanded, value);
                if (value)
                {
                    Expander1IsExpanded = false;
                }
            }
        }
        #endregion


        public ProductViewModel()
        {
            Product = new ObservableCollection<Product>();

            _ = LoadProductDataAsync();

            AddProductCommand = new RelayCommand(OnAddProductCommandExecuted, CanAddProductCommandExecute);

            UpdateProductCommand = new RelayCommand(OnUpdateProductCommandExecuted, CanUpdateProductCommandExecute);

            DeleteProductCommand = new RelayCommand(OnDeleteProductCommandExecuted, CanDeleteProductCommandExecute);
        }
    }
}
