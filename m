From: "Ameya Mitragotri" <ameya.mitragotri@wipro.com>
Date: Mon, 10 Nov 2003 05:14:02 +0000
Subject: RE: problem in booting HP zx6000 with stock kernel 2.5.75
Message-Id: <marc-linux-ia64-106844064515711@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106840426422921@msgid-missing>
In-Reply-To: <marc-linux-ia64-106840426422921@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

"Deepak Kumar Gupta, Noida" <dkumar@noida.hcltech.com> wrote in message
news:<Q08Y.87p.3@gated-at.bofh.it>...
> 5. The kernel hangs after uncompressing the kernel successfully.
Nothing is
> working here, neither keyboard nor anything else.

Which SCSI driver is configured? I had a qla driver and i faced a
panic while booting 2.6.0-test5. This patch solved my problem

http://www.ussg.iu.edu/hypermail/linux/kernel/0309.2/0331.html

Hope that helps,
Ameya


