From: Zoltan Menyhart <Zoltan.Menyhart_AT_bull.net@nospam.org>
Date: Mon, 20 Oct 2003 14:38:54 +0000
Subject: re: Rework arch/ia64/kernel/salinfo.c for 2.4
Message-Id: <marc-linux-ia64-106666078703118@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106664704821234@msgid-missing>
In-Reply-To: <marc-linux-ia64-106664704821234@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Keith,

I did see an uncorrectable cache error (MCA) and a corrected
memory error (CMC) in a single SAL error log record.
Can you sort out such a case ?

Is there any use to show the log of INIT ?

/* save last 5 records from mca.c, must be < 255 */
struct salinfo_data: struct salinfo_data_saved data_saved[5]; :

It would be much more safe for the MCA stuff to reserve a data
buffer for each CPU. As there is no mutual exclusion with the
MCA handler:
- do not "clear" nor "shift" MCA logs
- the MCA handler can overwrite the buffer of the CPU on which
  it executes
- for the "read <n>" command, you may:
  + calculate a CRC32 of the buffer[n]
  + copy_to_user(buffer[n],...)
  + calculate again the CRC32 of the buffer[n] and restart
    if it is not the same as before

Assuming I've got a CPE, can I read its SAL log on any CPU ?
Can I clear this SAL log on a different CPU ?

If a CMC's SAL log includes some Platform ... Error Info
structures and another CPU can pinch the platform related
error information (and it can clear it too), how can the CPU
causing the error know what has happened ?

Assuming I've got a CMC / CPE, I read its log but I do not clear it.
Assuming I've got another CMC / CPE and I read the log: are the
new / old errors merged ?

Thanks,

Zoltan Menyhart
