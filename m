From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 05 Jan 2004 20:10:14 +0000
Subject: RE: segv at strcmp
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F4FAFEA@scsmsx401.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040105190848.66033.qmail@web60006.mail.yahoo.com>
In-Reply-To: <20040105190848.66033.qmail@web60006.mail.yahoo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The <bits/string2.h> on my machine (came from the
glibc-devel-2.3.2-63 package in RedHat EL3). Looks
like it will only convert a strcmp to a memcmp if
*both* the arguments are constant:

# define strcmp(s1, s2) \
  __extension__                                                               \
  ({ size_t __s1_len, __s2_len;                                               \
     (__builtin_constant_p (s1) && __builtin_constant_p (s2)                  \
      && (__s1_len = strlen (s1), __s2_len = strlen (s2),                     \
          (!__string2_1bptr_p (s1) || __s1_len >= 4)                          \
          && (!__string2_1bptr_p (s2) || __s2_len >= 4))                      \
      ? memcmp ((__const char *) (s1), (__const char *) (s2),                 \
                (__s1_len < __s2_len ? __s1_len : __s2_len) + 1)              \
      : (__builtin_constant_p (s1) && __string2_1bptr_p (s1)                  \
         && (__s1_len = strlen (s1), __s1_len < 4)                            \
         ? (__builtin_constant_p (s2) && __string2_1bptr_p (s2)               \
            ? __strcmp_cc (s1, s2, __s1_len)                                  \
            : __strcmp_cg (s1, s2, __s1_len))                                 \
         : (__builtin_constant_p (s2) && __string2_1bptr_p (s2)               \
            && (__s2_len = strlen (s2), __s2_len < 4)                         \
            ? (__builtin_constant_p (s1) && __string2_1bptr_p (s1)            \
               ? __strcmp_cc (s1, s2, __s2_len)                               \
               : __strcmp_gc (s1, s2, __s2_len))                              \
            : strcmp (s1, s2)))); })

(I say "looks like" because I'm getting dizzy trying to match
parentheses in that expression).  Clearly your test case managed
to convert to memcmp when the first argument was not a constant
string ... which caused you grief.

-Tony
