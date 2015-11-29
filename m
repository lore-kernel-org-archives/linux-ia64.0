From: =?UTF-8?Q?Geyslan_Greg=C3=B3rio_Bem?= <geyslan@gmail.com>
Date: Sun, 29 Nov 2015 14:02:11 +0000
Subject: [RFC] arch/ia64/kernel/palinfo.c: bitvector_process reading out of bounds
Message-Id: <CAGG-pUSKM=FZc=Ceft3U9iEhzpgQA-QXF3P0AvJ+m-3Lm7zNkw@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

Hello,

I'm doing some static analysis and stumbled in this function

static void bitvector_process(struct seq_file *m, u64 vector)
{
    int i,j;
    static const char *units[]={ "", "K", "M", "G", "T" };

    for (i=0, j=0; i < 64; i++ , j=i/10) {
        if (vector & 0x1)
            seq_printf(m, "%d%s ", 1 << (i-j*10), units[j]);
        vector >>= 1;
    }
}

It appears that units[] (5 elements) can be accessed out of bounds in
seq_printf call

            seq_printf(m, "%d%s ", 1 << (i-j*10), units[j]);

once j is being set to i/10.

i goes from 0 to 63 (u64 bits length), and when vector & 1 (odd),
units[j] will calculate outside the boundaries when vector get close
to Petabyte magnitude.

Well, as bitvector_process doesn't control the max size of vector and
the future is knocking on door, I would suggest this change

-static const char *units[]={ "", "K", "M", "G", "T" };
+static const char *units[]={ "", "K", "M", "G", "T", "P", "E" };

then if the u64 max value (18446744073709551615) is used the array
will provide the correct (E) suffix.

If that change is not pertinent I would like to know why.

-- 
Regards,

Geyslan G. Bem
hackingbits.com
