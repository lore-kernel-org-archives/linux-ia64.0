From: Ian Wienand <ianw@gelato.unsw.edu.au>
Date: Wed, 20 Aug 2003 01:24:14 +0000
Subject: generic kernel on the simulator
Message-Id: <marc-linux-ia64-106134305414419@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

Should a generic kernel be able to boot on the simulator?  The kernel
seems to build in machine vector information for the simulator, but
I'm not sure if the simulator simulates enough for the init routines
to discover this?

-i
ianw@gelato.unsw.edu.au
http://www.gelato.unsw.edu.au
