using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.ComponentModel;
using System.Data.SqlClient;
using System.Linq;
using System.Runtime.CompilerServices;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Input;
using Fintech_Test_.Commands;
using Fintech_Test_.Model;
using Fintech_Test_.Model.DataContext;
using Microsoft.EntityFrameworkCore;

namespace Fintech_Test_.ViewModel
{
    internal class MainViewModel : INotifyPropertyChanged
    {
        private ObservableCollection<Links> _links;

        public ObservableCollection<Links> Links
        {
            get => _links;
            set => Set(ref _links, value);
        }

        
        
        
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
        
        public Product SelectedProduct
        {
            get { return _selectedProduct; }
            set { Set(ref _selectedProduct, value); }
        }


        public async Task LoadDataAsync()
        {
            using (var context = new ApplicationContext())
            {
                //Links = new ObservableCollection<Links>(await context.Links.ToListAsync());
                Product = new ObservableCollection<Product>(await context.Product.ToListAsync());
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
                await LoadDataAsync();
            }
        }

        #endregion

        #region Изменить Product

        public ICommand UpdateProductCommand { get; }
        private bool CanUpdateProductCommandExecute(object parameter) => true;
        private async void OnUpdateProductCommandExecuted(object parameter)
        {
            await UpdateProductAsync();
        }
        private async Task UpdateProductAsync()
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
                    await LoadDataAsync();
                }
            }
        }

        #endregion

        #region Удалить Product

        public ICommand DeleteProductCommand { get; }
        private bool CanDeleteProductCommandExecute(object parameter) => true;
        private async void OnDeleteProductCommandExecuted(object parameter)
        {
            await DeleteProductAsync();
        }
        private async Task DeleteProductAsync()
        {
            using (var context = new ApplicationContext())
            {
                if (SelectedProduct != null)
                {
                    context.Product.Remove(SelectedProduct);
                    await context.SaveChangesAsync();


                    SelectedProduct = null;

                    await LoadDataAsync();
                }
            }
        }

        #endregion
        #endregion

        
       
        #region Links
        #region Добавить Links
        #endregion
        #region Изменить Links 
        #endregion
        #region Удалить Links
        #endregion
        #endregion


        #region Визульные улучшения
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


        public MainViewModel()
        {
            Product = new ObservableCollection<Product>();
            Links = new ObservableCollection<Links>();

            _ = LoadDataAsync();

            AddProductCommand = new RelayCommand(OnAddProductCommandExecuted, CanAddProductCommandExecute);

            UpdateProductCommand = new RelayCommand(OnUpdateProductCommandExecuted, CanUpdateProductCommandExecute);

            DeleteProductCommand = new RelayCommand(OnDeleteProductCommandExecuted, CanDeleteProductCommandExecute);
        
        
        
        }
        
        

        public event PropertyChangedEventHandler? PropertyChanged;

        protected virtual void OnPropertyChanged([CallerMemberName] string? PropertyName = null)
        {
            PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(PropertyName));
        }

        protected virtual bool Set<T>(ref T field, T value, [CallerMemberName] string? PropertyName = null)
        {
            if (Equals(field, value)) return false;
            field = value;
            OnPropertyChanged(PropertyName);
            return true;
        }
    }
}
