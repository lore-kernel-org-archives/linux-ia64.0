From: Christian Hildner <christian.hildner@hob.de>
Date: Mon, 10 Mar 2003 15:29:03 +0000
Subject: [Linux-ia64] relocatable switch - case
Message-Id: <marc-linux-ia64-105590709806017@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

does anybody here know how to force gcc to compile a switch statement to 
position independend, fully relocatable code that uses mov rx=ip to get 
the address of the switch-table/program address. I only found solutions 
where the address is loaded via gp (which is not suitable for me).

Any help is appreciated.

Christian


