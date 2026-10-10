using System;
using System.Security.Cryptography;
using System.Text;

namespace MeowletEducation
{
    // One-time access codes that let a new admin account in. An existing admin
    // generates one from the dashboard notifications (AdminNotifications.ashx)
    // and the new admin enters it on AdminAccessCode.aspx.
    internal static class AdminAccessCodes
    {
        // No 0/O, 1/I/L: the code is read out or copied by hand.
        private const string Alphabet = "ABCDEFGHJKMNPQRSTUVWXYZ23456789";

        public const int Length = 8;
        public const int MaxFailedTries = 5;
        public static readonly TimeSpan Lifetime = TimeSpan.FromHours(24);

        public static string Generate()
        {
            // Bytes at or above the last whole multiple of the alphabet size are
            // skipped, so every character is equally likely.
            int limit = 256 - (256 % Alphabet.Length);
            var sb = new StringBuilder(Length);
            var one = new byte[1];

            using (var rng = RandomNumberGenerator.Create())
            {
                while (sb.Length < Length)
                {
                    rng.GetBytes(one);
                    if (one[0] < limit) sb.Append(Alphabet[one[0] % Alphabet.Length]);
                }
            }

            return sb.ToString();
        }

        // Upper-cases and drops spaces and dashes, so "abcd-efgh" matches "ABCDEFGH".
        public static string Normalize(string code)
        {
            var sb = new StringBuilder();
            foreach (char c in code ?? string.Empty)
            {
                if (c != ' ' && c != '-') sb.Append(char.ToUpperInvariant(c));
            }
            return sb.ToString();
        }

        public static string Hash(string code)
        {
            using (var sha = SHA256.Create())
            {
                byte[] bytes = sha.ComputeHash(Encoding.UTF8.GetBytes(Normalize(code)));
                var sb = new StringBuilder();
                foreach (byte b in bytes) sb.Append(b.ToString("x2"));
                return sb.ToString();
            }
        }

        // Compares every character so the time taken doesn't hint at how much matched.
        public static bool HashesMatch(string given, string expected)
        {
            if (given == null || expected == null || given.Length != expected.Length) return false;
            int diff = 0;
            for (int i = 0; i < given.Length; i++) diff |= given[i] ^ expected[i];
            return diff == 0;
        }
    }
}
