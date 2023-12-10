using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using OfficeOpenXml;
using System.Data.SqlClient;
using System.IO;
using System.Windows.Input;
using Microsoft.Win32;
using Fintech_Test_.ViewModel.Command;
using System.Data;
using Fintech_Test_.Model;
using System.Collections.ObjectModel;
using Fintech_Test_.Model.DataContext;
using static Microsoft.EntityFrameworkCore.DbLoggerCategory.Database;
using Microsoft.EntityFrameworkCore;

namespace Fintech_Test_.ViewModel
{
    class ReportViewModel : ViewModelBase
    {
        private ObservableCollection<Report> _dataReport;        
        public ObservableCollection<Report> DataReport
        {
            get => _dataReport;
            set => Set(ref _dataReport, value);
        }


        public ICommand LoadReportDataCommand { get; }
        private bool CanLoadReportDataCommandExecute(object parameter) => true;
        private async void OnLoadReportDataCommandExecuted(object parameter)
        {
            await LoadReportDataAsync();
        }

        public async Task LoadReportDataAsync()
        {
            using (var context = new ApplicationContext())
            {
                DataReport = new ObservableCollection<Report>(await context.ReportForProductLinks.FromSqlRaw("EXEC ReportForProductLinks").ToListAsync());
            }
        }


        //private void LoadData()
        //{
        //    using (var context = new YourDbContext())
        //    {
        //        var sql = "EXEC GetMyData";
        //        var adapter = new SqlDataAdapter(sql, context.Database.Connection.ConnectionString);
        //        var dataSet = new DataSet();
        //        adapter.Fill(dataSet);

        //        DataTable = dataSet.Tables.Count > 0 ? dataSet.Tables[0] : null;
        //    }
        //}




        //private void LoadData()
        //{
        //    using (var context = new YourDbContext()) // Замените YourDbContext на ваш контекст базы данных
        //    {
        //        var dataTable = new DataTable();
        //        using (var command = context.Database.Connection.CreateCommand())
        //        {
        //            command.CommandText = "EXEC GetMyData";
        //            context.Database.Connection.Open();
        //            using (var reader = command.ExecuteReader())
        //            {
        //                dataTable.Load(reader);
        //            }
        //        }

        //        Data = dataTable;
        //    }
        //}




        //private void ExportToExcel()
        //{
        //    using (var package = new ExcelPackage())
        //    {
        //        var worksheet = package.Workbook.Worksheets.Add("Data");

        //        // Получаем данные из базы данных
        //        using (var connection = new SqlConnection("your_connection_string"))
        //        {
        //            connection.Open();
        //            using (var command = new SqlCommand("SELECT * FROM YourTableName", connection))
        //            using (var reader = command.ExecuteReader())
        //            {
        //                int col = 1;
        //                for (int i = 0; i < reader.FieldCount; i++)
        //                {
        //                    worksheet.Cells[1, col].Value = reader.GetName(i);
        //                    col++;
        //                }

        //                int row = 2;
        //                while (reader.Read())
        //                {
        //                    col = 1;
        //                    for (int i = 0; i < reader.FieldCount; i++)
        //                    {
        //                        worksheet.Cells[row, col].Value = reader[i];
        //                        col++;
        //                    }
        //                    row++;
        //                }
        //            }
        //        }

        //        // Сохраняем файл Excel
        //        var saveFileDialog = new SaveFileDialog
        //        {
        //            Filter = "Excel files (*.xlsx)|*.xlsx|All files (*.*)|*.*",
        //            FileName = "ExportedData.xlsx"
        //        };

        //        if (saveFileDialog.ShowDialog() == DialogResult.OK)
        //        {
        //            var excelFile = new FileInfo(saveFileDialog.FileName);
        //            package.SaveAs(excelFile);
        //        }
        //    }
        //}

        public ReportViewModel()
        {
            _ = LoadReportDataAsync();

            LoadReportDataCommand = new RelayCommand(OnLoadReportDataCommandExecuted);
        } 
    }
}
