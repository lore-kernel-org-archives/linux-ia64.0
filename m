From: Mario Smarduch <cms063@email.mot.com>
Date: Wed, 25 Feb 2004 21:35:24 +0000
Subject: General question about building kernel.org distros
Message-Id: <403D151C.1F7A96D1@email.mot.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

I just have a general question regarding building IA64 2.4.25
stock kernel from kernel.org. After downloading, and building
with the default  config there were tons of compile errors. These were
some obvious errors like functions accepting more or less
parameters then call sites were providing and tons of other
obvious errors independent of the configuration. Eventually
I plugged up all the errors and the thing comes up and seems
to stay up.

Is this sort of normal when building a source tree from kernel.org
for IA64 or am I missing something?

For i386 I have no problems like that. I'm a bit concerned
if a vendor uses this as base for a distribution and has
to plug up all these holes, you kind of wonder if there are
any bugs  left behind.

- Mario.

