using Fintech_Test_.Model;
using Fintech_Test_.Model.DataContext;
using Fintech_Test_.ViewModel.Command;
using Microsoft.EntityFrameworkCore;
using System.Collections.ObjectModel;
using System.Windows;
using System.Windows.Input;

namespace Fintech_Test_.ViewModel
{
    class LinksViewModel : ViewModelBase
    {
        #region Links

        private ObservableCollection<Links> _links;
        private long? _upProductId;
        private long _productId;
        private int _count;
        private Links? _selectedLinks;

        public ObservableCollection<Links> Links
        {
            get => _links;
            set => Set(ref _links, value);
        }

        public long? UpProductId
        {
            get => _upProductId;
            set => Set(ref _upProductId, value);
        }

        public long ProductId
        {
            get => _productId;
            set => Set(ref _productId, value);
        }

        public int Count
        {
            get => _count;
            set => Set(ref _count, value);
        }

        public Links? SelectedLinks
        {
            get { return _selectedLinks; }
            set { Set(ref _selectedLinks, value); }
        }

        private ObservableCollection<Product> _upProduct;
        public ObservableCollection<Product> UpProduct
        {
            get => _upProduct;
            set => Set(ref _upProduct, value);
        }


        private ObservableCollection<Product> _product;
        public ObservableCollection<Product> Product
        {
            get => _product;
            set => Set(ref _product, value);
        }

        public ICommand LoadLinksDataAsyncCommand { get; }
        private bool CanLoadLinksDataAsyncCommandExecute(object parameter) => true;
        private async void OnLoadLinksDataAsyncCommandExecuted(object parameter)
        {
            await LoadLinksDataAsync();
        }

        public async Task LoadLinksDataAsync()
        {
            try
            {
                using (var context = new ApplicationContext())
                {
                    Links = new ObservableCollection<Links>(await context.Links
                                                            .Include(l => l.UpProduct)
                                                            .Include(l => l.Product)
                                                            .ToListAsync());

                    UpProduct = new ObservableCollection<Product>(await context.Product.ToListAsync());
                    UpProduct.Insert(0, new Product { Name = "Null", Id = null });

                    Product = new ObservableCollection<Product>(await context.Product.ToListAsync());                
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show($"An error occurred: {ex.Message}", "Error", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }



        #region Добавить Links        

        public ICommand AddLinksCommand { get; }
        private bool CanAddLinksCommandExecute(object parameter) => true;
        private async void OnAddLinksCommandExecuted(object parameter)
        {
            await AddLinksAsync();
        }

        private async Task AddLinksAsync()
        {
            try
            {
                using (var context = new ApplicationContext())
                {
                    var newLinks = new Links
                    {
                        UpProductId = UpProductId,
                        ProductId = ProductId,
                        Count = Count
                    };
                    context.Links.Add(newLinks);
                    await context.SaveChangesAsync();
                    Links.Add(newLinks);

                    UpProductId = null;
                    ProductId = 0;
                    Count = 0;
                    await LoadLinksDataAsync();
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show($"An error occurred: {ex.Message}", "Error", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        #endregion



        #region Изменить Links

        public ICommand UpdateLinksCommand { get; }
        private bool CanUpdateLinksCommandExecute(object parameter) => SelectedLinks != null ? true : false;

        private async void OnUpdateLinksCommandExecuted(object parameter)
        {
            await UpdateLinksAsync();
        }
        private async Task UpdateLinksAsync()
        {
            try
            {
                using (var context = new ApplicationContext())
                {
                    if (SelectedLinks != null)
                    {
                        Product selectedProduct = context.Product.Find(SelectedLinks.ProductId);
                        Product selectedUpProduct = context.Product.Find(SelectedLinks.UpProductId);

                        SelectedLinks.Product = selectedProduct;
                        SelectedLinks.UpProduct = selectedUpProduct;

                        context.Links.Update(SelectedLinks);
                        await context.SaveChangesAsync();

                        SelectedLinks = null;
                        UpProductId = null;
                        ProductId = 0;
                        Count = 0;
                        await LoadLinksDataAsync();
                    }
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show($"An error occurred: {ex.Message}", "Error", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        #endregion



        #region Удалить Links

        public ICommand DeleteLinksCommand { get; }
        private bool CanDeleteLinksCommandExecute(object parameter) => SelectedLinks != null ? true : false;
        private async void OnDeleteLinksCommandExecuted(object parameter)
        {
            await DeleteLinksAsync();
        }
        private async Task DeleteLinksAsync()
        {
            using (var context = new ApplicationContext())
            {
                if (SelectedLinks != null)
                {
                    context.Links.Remove(SelectedLinks);
                    await context.SaveChangesAsync();

                    SelectedLinks = null;
                    await LoadLinksDataAsync();
                }
            }
        }

        #endregion

        #endregion



        public LinksViewModel()
        {
            Links = new ObservableCollection<Links>();

            _ = LoadLinksDataAsync();

            LoadLinksDataAsyncCommand = new RelayCommand(OnLoadLinksDataAsyncCommandExecuted, CanLoadLinksDataAsyncCommandExecute);

            AddLinksCommand = new RelayCommand(OnAddLinksCommandExecuted, CanAddLinksCommandExecute);

            UpdateLinksCommand = new RelayCommand(OnUpdateLinksCommandExecuted, CanUpdateLinksCommandExecute);

            DeleteLinksCommand = new RelayCommand(OnDeleteLinksCommandExecuted, CanDeleteLinksCommandExecute);
        }
    }
}
