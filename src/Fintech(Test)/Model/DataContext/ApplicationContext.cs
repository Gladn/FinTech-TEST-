using Microsoft.EntityFrameworkCore;

namespace Fintech_Test_.Model.DataContext
{
    class ApplicationContext : DbContext
    {
        public DbSet<Product>? Product { get; set; }
        public DbSet<Links>? Links { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            modelBuilder.Entity<Product>().Property(p => p.Id).ValueGeneratedOnAdd();
            modelBuilder.Entity<Links>().HasNoKey();               
        }
        protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
        {
            optionsBuilder.UseSqlServer("Data Source=localhost;Initial Catalog=Fintech;Integrated Security=True;TrustServerCertificate=True");
        }
    }
}
