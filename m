From: CH Gowri Kumar <gkumar@csa.iisc.ernet.in>
Date: Tue, 29 Jul 2003 21:54:57 +0000
Subject: Conversion between different types on IA-64
Message-Id: <marc-linux-ia64-105951522415896@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi all,
Can anyone point me to a source of how to convert from a 
wider size to narrow size (long to int, int to char etc.) on IA-64?

For the other way round(narrow to wider), I could find SXT(sign extend) 
and ZXT(zero extend) instructions.

gcc seems(but not sure) to be storing the original value and loading it 
using the appropriate LD* instruction.

I am sorry if it's a too trivial question to be asked on this list.

Regards,
Gowri Kumar


