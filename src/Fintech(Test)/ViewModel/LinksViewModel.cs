using Fintech_Test_.Model.DataContext;
using Fintech_Test_.Model;
using Fintech_Test_.ViewModel.Command;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Input;
using Microsoft.EntityFrameworkCore;

namespace Fintech_Test_.ViewModel
{
    class LinksViewModel : ViewModelBase
    {
        #region Links

        private ObservableCollection<Links> _links;
        private long _productID;
        private long? _upProductId;
        private int _count;
        private Links _selectedLinks;

        public ObservableCollection<Links> Links
        {
            get => _links;
            set => Set(ref _links, value);
        }

        public long ProductID
        {
            get => _productID;
            set => Set(ref _productID, value);
        }

        public long? UpProductID
        {
            get => _upProductId;
            set => Set(ref _upProductId, value);
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


        public async Task LoadLinksDataAsync()
        {
            using (var context = new ApplicationContext())
            {
                Links = new ObservableCollection<Links>(await context.Links
                                                        .Include(l => l.Product)
                                                        .Include(l => l.UpProduct)
                                                        .ToListAsync());
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
            using (var context = new ApplicationContext())
            {
                var newLinks = new Links
                {
                    ProductId = ProductID,
                    UpProductId = UpProductID,
                    Count = Count
                };
                context.Links.Add(newLinks);
                await context.SaveChangesAsync();
                Links.Add(newLinks);


                Count = 0;
                await LoadLinksDataAsync();
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
            using (var context = new ApplicationContext())
            {
                if (SelectedLinks != null)
                {
                    ProductID = SelectedLinks.ProductId;
                    UpProductID = SelectedLinks.UpProductId;
                    Count = SelectedLinks.Count;


                    context.Links.Update(SelectedLinks);
                    await context.SaveChangesAsync();

                    SelectedLinks = null;
                    Count = 0;
                    await LoadLinksDataAsync();
                }
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

            AddLinksCommand = new RelayCommand(OnAddLinksCommandExecuted, CanAddLinksCommandExecute);

            UpdateLinksCommand = new RelayCommand(OnUpdateLinksCommandExecuted, CanUpdateLinksCommandExecute);

            DeleteLinksCommand = new RelayCommand(OnDeleteLinksCommandExecuted, CanDeleteLinksCommandExecute);
        }
    }
}
