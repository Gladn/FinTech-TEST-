﻿using Microsoft.EntityFrameworkCore;

namespace Fintech_Test_.Model.DataContext
{
    class ApplicationContext : DbContext
    {
        public DbSet<Product>? Product { get; set; }
        public DbSet<Links>? Links { get; set; }


        public DbSet<Report> ReportForProductLinks { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            modelBuilder.Entity<Product>().Property(p => p.Id).ValueGeneratedOnAdd();
            modelBuilder.Entity<Links>().Property(p => p.LinkId).ValueGeneratedOnAdd();
            modelBuilder.Entity<Report>().HasNoKey();
        }
        protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
        {
            optionsBuilder.UseSqlServer("Data Source=localhost;Initial Catalog=Fintech;Integrated Security=True;TrustServerCertificate=True;Connect Timeout=5");
        }
    }
}