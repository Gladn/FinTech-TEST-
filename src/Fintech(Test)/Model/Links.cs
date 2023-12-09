using System.ComponentModel.DataAnnotations.Schema;

namespace Fintech_Test_.Model
{
    [Table("Links")]
    public class Links
    {
        public long UpProductId { get; set; }
        public long ProductId { get; set; }
        public int Count { get; set; }

        public Product? Product { get; set; }
        public Product? UpProduct { get; set; }
    }
}
