From: "Karthik Gopalakrishnan" <karthik.g.krishnan@gmail.com>
Date: Fri, 08 Dec 2006 20:42:10 +0000
Subject: MCA in console_init()
Message-Id: <5e0a1fd80612081230j20db7772nfabb6e1609ea0fd8@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Folks.

    I am trying to debug an MCA that I hit during kernel bootup. I
have isolated the problem to the while loop in the console_init()
routine called as part of start_kernel(). The IIP obtained from the
MCA Logs point to vgacon_startup(). I will be grateful if someone
could tell me how execution lands up in vgacon_startup() from
console_init() since I didn't understand that part of code. Any
document on the low level console initialization would also help.

Thanks & Regards,
Karthik
