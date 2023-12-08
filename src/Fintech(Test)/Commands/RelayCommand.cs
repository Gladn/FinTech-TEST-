using System.Windows.Input;

namespace Fintech_Test_.Commands
{
    class RelayCommand : ICommand
    {
        private readonly Action<object?> _Execute;
        private readonly Func<object?, bool> _CanExecute;

        public event EventHandler? CanExecuteChanged
        {
            add => CommandManager.RequerySuggested += value;
            remove => CommandManager.RequerySuggested -= value;
        }

        public RelayCommand(Action<object?> Execute, Func<object?, bool> CanExecute = null)
        {
            _Execute = Execute ?? throw new ArgumentNullException(nameof(Execute));
            _CanExecute = CanExecute;
        }

        public bool CanExecute(object? parameter) => _CanExecute?.Invoke(parameter) ?? true;
        public void Execute(object? parameter) => _Execute(parameter);
    }
}
