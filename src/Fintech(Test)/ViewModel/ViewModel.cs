using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using System.Runtime.CompilerServices;
using System.Text;
using System.Threading.Tasks;

namespace Fintech_Test_.ViewModel
{
    internal class ViewModel : INotifyPropertyChanged
    {

        #region Product 

        #region Отобразить Product

        #endregion

        #region Добавить Product 

        #endregion

        #region Удалить Product

        #endregion

        #endregion


        #region Links

        #region Отобразить Links

        #endregion

        #region Добавить Links 

        #endregion

        #region Удалить Links

        #endregion

        #endregion



        public event PropertyChangedEventHandler PropertyChanged;

        protected virtual void OnPropertyChanged(string propertyName)
        {
            PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(propertyName));
        }
    }
}
