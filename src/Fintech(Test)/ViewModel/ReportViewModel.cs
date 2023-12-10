using Fintech_Test_.Model;
using Fintech_Test_.Model.DataContext;
using Fintech_Test_.ViewModel.Command;
using Microsoft.EntityFrameworkCore;
using OfficeOpenXml;
using System.Collections.ObjectModel;
using System.Diagnostics;
using System.Windows;
using System.Windows.Input;


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
        private async void OnLoadReportDataCommandExecuted(object parameter)
        {
            await LoadReportDataAsync();
        }

        public async Task LoadReportDataAsync()
        {
            try
            {
                using (var context = new ApplicationContext())
                {
                    DataReport = new ObservableCollection<Report>(await context.ReportForProductLinks.FromSqlRaw("EXEC ReportForProductLinks").ToListAsync());
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show($"An error occurred: {ex.Message}", "Error", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }


        public ICommand LoadReportDataExcelCommand { get; }
        private async void OnLoadReportDataExcelCommandExecuted(object parameter)
        {
            await LoadReportDataExcelAsync();
        }

        public async Task LoadReportDataExcelAsync()
        {
            try
            {
                using (ExcelPackage package = new ExcelPackage())
                {
                    ExcelWorksheet worksheet = package.Workbook.Worksheets.Add("Report");

                    ExcelColumn column2 = worksheet.Column(2); column2.Width = 25;
                    ExcelColumn column3 = worksheet.Column(3); column3.Width = 15;
                    ExcelColumn column4 = worksheet.Column(4); column4.Width = 10;
                    ExcelColumn column5 = worksheet.Column(5); column5.Width = 15;
                    ExcelColumn column6 = worksheet.Column(6); column6.Width = 20;

                    worksheet.Cells[2, 2].Value = "Название";
                    worksheet.Cells[2, 3].Value = "Количество";
                    worksheet.Cells[2, 4].Value = "Цена";
                    worksheet.Cells[2, 5].Value = "Стоимость";
                    worksheet.Cells[2, 6].Value = "Кол-во входящих";


                    for (int i = 0; i < DataReport.Count; i++)
                    {
                        worksheet.Cells[i + 3, 2].Value = DataReport[i].Name;
                        worksheet.Cells[i + 3, 3].Value = DataReport[i].Count;
                        worksheet.Cells[i + 3, 4].Value = DataReport[i].Price;
                        worksheet.Cells[i + 3, 5].Value = DataReport[i].AmountChildTotalCost;
                        worksheet.Cells[i + 3, 6].Value = DataReport[i].AmountChildCount;
                    }

                    using (var range = worksheet.Cells[2, 2, 2, 20])
                    {
                        range.Style.Font.Size = 14;
                    }

                    for (int i = 1; i <= DataReport.Count + 2; i++)
                    {
                        using (var range = worksheet.Cells[i, 2, i, 20])
                        {
                            range.Style.Font.Size = 14;
                        }
                    }


                    var saveFileDialog = new Microsoft.Win32.SaveFileDialog
                    {
                        Filter = "Excel files (*.xlsx)|*.xlsx|All files (*.*)|*.*",
                        FileName = "Report.xlsx"
                    };


                    if (saveFileDialog.ShowDialog() == true)
                    {
                        var fileInfo = new System.IO.FileInfo(saveFileDialog.FileName);
                        package.SaveAs(fileInfo);
                        try
                        {
                            Process.Start(new ProcessStartInfo
                            {
                                FileName = fileInfo.FullName,
                                UseShellExecute = true
                            });
                        }
                        catch (Exception ex)
                        {
                            MessageBox.Show($"Ошибка при открытии файла: {ex.Message}", "Ошибка", MessageBoxButton.OK, MessageBoxImage.Error);
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show($"An error occurred: {ex.Message}", "Error", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }


        public ReportViewModel()
        {
            _ = LoadReportDataAsync();

            LoadReportDataCommand = new RelayCommand(OnLoadReportDataCommandExecuted);

            LoadReportDataExcelCommand = new RelayCommand(OnLoadReportDataExcelCommandExecuted);
        }
    }
}
