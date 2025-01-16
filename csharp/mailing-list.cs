// A CSharp Program to read from the database table mailing_list and send email messages to each recipient in the table.
// The program is designed to be run as a scheduled task, and will send messages to all recipients in the table that have not yet been sent.
// The program will send messages to the recipients in the order they were added to the table.
// Send emails in batches of 100, and wait 1 second between each batch.

using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.IO;
using System.Net;
//using System.Net.Mail;
using System.Threading.Tasks;
using Moq;
using VaultSharp;
using VaultSharp.V1.AuthMethods.OIDC;
using VaultSharp.V1.Commons;
using Xunit;

class Program
{
    static async Task Main(string[] args)
    {
        string connectionString = "your_connection_string_here";
        // Read database connection credentials from Vault using an OIDC connection
        var vaultClient = new VaultClient(new VaultClientSettings("https://vault-server:8200", new OidcAuthMethodInfo("your_oidc_role")));
        var secret = await vaultClient.V1.Secrets.KeyValue.V2.ReadSecretAsync("path/to/your/secret");
        connectionString = secret.Data["connection_string"].ToString();
        string selectQuery = "SELECT Id, Email, FirstName, LastName FROM mailing_list WHERE Sent = 0 ORDER BY Id";
        string updateQuery = "UPDATE mailing_list SET Sent = 1 WHERE Id = @Id";

        // Read the message body from a file
        string messageTemplate = await File.ReadAllTextAsync("path/to/message_template.txt");

        List<MailMessage> messages = new List<MailMessage>();

        using (SqlConnection connection = new SqlConnection(connectionString))
        {
            await connection.OpenAsync();
            using (SqlCommand command = new SqlCommand(selectQuery, connection))
            using (SqlDataReader reader = await command.ExecuteReaderAsync())
            {
                while (await reader.ReadAsync())
                {
                    int id = reader.GetInt32(0);
                    string email = reader.GetString(1);
                    string firstName = reader.GetString(2);
                    string lastName = reader.GetString(3);

                    // Replace placeholders with actual values
                    string message = messageTemplate.Replace("{FirstName}", firstName).Replace("{LastName}", lastName);

                    MailMessage mailMessage = new MailMessage("your_email@example.com", email, "Subject", message);
                    mailMessage.Tag = id;
                    messages.Add(mailMessage);
                }
            }
        }

        SmtpClient smtpClient = new SmtpClient("your_smtp_server")
        {
            Port = 587,
            Credentials = new NetworkCredential("your_username", "your_password"),
            EnableSsl = true,
        };

        for (int i = 0; i < messages.Count; i += 100)
        {
            List<Task> tasks = new List<Task>();

            for (int j = i; j < i + 100 && j < messages.Count; j++)
            {
                tasks.Add(SendEmailAsync(smtpClient, messages[j], connectionString, updateQuery));
            }

            await Task.WhenAll(tasks);
            await Task.Delay(1000);
        }
    }

    static async Task SendEmailAsync(SmtpClient smtpClient, MailMessage mailMessage, string connectionString, string updateQuery)
    {
        try
        {
            await smtpClient.SendMailAsync(mailMessage);

            using (SqlConnection connection = new SqlConnection(connectionString))
            {
                await connection.OpenAsync();
                using (SqlCommand command = new SqlCommand(updateQuery, connection))
                {
                    command.Parameters.AddWithValue("@Id", mailMessage.Tag);
                    await command.ExecuteNonQueryAsync();
                }
            }
        }
        catch (Exception ex)
        {
            Console.WriteLine($"Failed to send email to {mailMessage.To}: {ex.Message}");
        }
    }

    public static async Task<string> GetConnectionStringFromVault(IVaultClient vaultClient)
    {
        var secret = await vaultClient.V1.Secrets.KeyValue.V2.ReadSecretAsync("path/to/your/secret");
        return secret.Data["connection_string"].ToString();
    }

    /// <summary>
    /// Sends emails to recipients from the mailing list in batches of 100.
    /// </summary>
    /// <param name="smtpClient">The SMTP client used to send emails.</param>
    /// <param name="sqlConnection">The SQL connection to the database.</param>
    /// <param name="messageTemplate">The message template with placeholders for first name and last name.</param>
    /// <returns>A task that represents the asynchronous operation.</returns>
    public static async Task SendEmails(SmtpClient smtpClient, SqlConnection sqlConnection, string messageTemplate)
    {
        string selectQuery = "SELECT Id, Email, FirstName, LastName FROM mailing_list WHERE Sent = 0 ORDER BY Id";
        string updateQuery = "UPDATE mailing_list SET Sent = 1 WHERE Id = @Id";

        List<MailMessage> messages = new List<MailMessage>();

        // Read recipients from the database
        using (SqlCommand command = new SqlCommand(selectQuery, sqlConnection))
        using (SqlDataReader reader = await command.ExecuteReaderAsync())
        {
            while (await reader.ReadAsync())
            {
                int id = reader.GetInt32(0);
                string email = reader.GetString(1);
                string firstName = reader.GetString(2);
                string lastName = reader.GetString(3);

                // Replace placeholders with actual values
                string message = messageTemplate.Replace("{FirstName}", firstName).Replace("{LastName}", lastName);

                MailMessage mailMessage = new MailMessage("your_email@example.com", email, "Subject", message);
                mailMessage.Tag = id;
                messages.Add(mailMessage);
            }
        }

        // Send emails in batches of 100
        for (int i = 0; i < messages.Count; i += 100)
        {
            List<Task> tasks = new List<Task>();

            for (int j = i; j < i + 100 && j < messages.Count; j++)
            {
                tasks.Add(SendEmailAsync(smtpClient, messages[j], sqlConnection.ConnectionString, updateQuery));
            }

            await Task.WhenAll(tasks);
            await Task.Delay(1000);
        }
    }
}

public class ProgramTests
{
    [Fact]
    public async Task TestConnectionStringRetrievalFromVault()
    {
        // Arrange
        var mockVaultClient = new Mock<IVaultClient>();
        var secret = new Secret<Dictionary<string, object>>
        {
            Data = new Dictionary<string, object> { { "connection_string", "test_connection_string" } }
        };
        mockVaultClient.Setup(v => v.V1.Secrets.KeyValue.V2.ReadSecretAsync(It.IsAny<string>(), null, null))
                       .ReturnsAsync(secret);

        // Act
        var connectionString = await Program.GetConnectionStringFromVault(mockVaultClient.Object);

        // Assert
        Assert.Equal("test_connection_string", connectionString);
    }

    [Fact]
    public async Task TestEmailSending()
    {
        // Arrange
        var mockSmtpClient = new Mock<SmtpClient>("smtp_server");
        var mockSqlConnection = new Mock<SqlConnection>("test_connection_string");
        var mockSqlCommand = new Mock<SqlCommand>();
        var mockSqlDataReader = new Mock<SqlDataReader>();

        mockSqlDataReader.SetupSequence(r => r.ReadAsync())
                         .ReturnsAsync(true)
                         .ReturnsAsync(false);
        mockSqlDataReader.Setup(r => r.GetInt32(0)).Returns(1);
        mockSqlDataReader.Setup(r => r.GetString(1)).Returns("test@example.com");
        mockSqlDataReader.Setup(r => r.GetString(2)).Returns("John");
        mockSqlDataReader.Setup(r => r.GetString(3)).Returns("Doe");

        mockSqlCommand.Setup(c => c.ExecuteReaderAsync()).ReturnsAsync(mockSqlDataReader.Object);
        mockSqlConnection.Setup(c => c.CreateCommand()).Returns(mockSqlCommand.Object);

        // Act
        await Program.SendEmails(mockSmtpClient.Object, mockSqlConnection.Object, "test_message_template");

        // Assert
        mockSmtpClient.Verify(s => s.SendMailAsync(It.IsAny<MailMessage>()), Times.Once);
    }
}