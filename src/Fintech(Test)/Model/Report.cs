using Microsoft.EntityFrameworkCore;

namespace Fintech_Test_.Model
{
    [Keyless]
    public class Report
    {
        public long? UpProductId { get; set; }
        public long ProductId { get; set; }
        public string? Name { get; set; }
        public int Count { get; set; }
        public decimal Price {  get; set; }
        public decimal AmountChildTotalCost { get; set; }
        public int AmountChildCount { get; set; }
        public int Level { get; set; }
    }
}
