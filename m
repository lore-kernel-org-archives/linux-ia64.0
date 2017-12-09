From: SF Markus Elfring <elfring@users.sourceforge.net>
Date: Sat, 09 Dec 2017 18:02:28 +0000
Subject: [PATCH 0/3] tty/serial/ioc3: Adjustments for three function implementations
Message-Id: <962f1172-3f27-c6b5-653f-c09f2e8fe431@users.sourceforge.net>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-serial@vger.kernel.org, linux-ia64@vger.kernel.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Jiri Slaby <jslaby@suse.com>, Pat Gefre <pfg@sgi.com>
Cc: LKML <linux-kernel@vger.kernel.org>, kernel-janitors@vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Sat, 9 Dec 2017 19:00:19 +0100

Three update suggestions were taken into account
from static source code analysis.

Markus Elfring (3):
  Delete error messages for a failed memory allocation in ioc3uart_probe()
  Improve size determinations in ioc3uart_probe()
  Adjust two function calls together with a variable assignment

 drivers/tty/serial/ioc3_serial.c | 22 +++++++++-------------
 1 file changed, 9 insertions(+), 13 deletions(-)

-- 
2.15.1

