From: Einar Saltnes <eisa@scali.no>
Date: Thu, 07 Dec 2000 14:59:13 +0000
Subject: [Linux-ia64] Re: fail to mount LS120 drive
Message-Id: <marc-linux-ia64-105590678205813@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205809@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205809@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Bill Nottingham wrote:
> 
> If you don't have a partitioned floppy, just mount the raw
> device, i.e.:
> 
> mount /dev/hdb -t <filesystem type> /mnt/floppy
> 
> Bill
> 
Thank you, it worked as expected. Now, over to the BIOS upgrade...

Einar
-- 
| Einar Saltnes          |         Scali AS         |
| mailto:eisa@scali.no   |   http://www.scali.com   |
| Phone:+47 22 62 89 50  |  Scalable Linux Systems  |
| Fax  :+47 22 62 89 51  |      and Technology      |

