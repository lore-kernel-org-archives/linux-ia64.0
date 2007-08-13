From: "Natalie Protasevich" <protasnb@gmail.com>
Date: Mon, 13 Aug 2007 17:42:11 +0000
Subject: BINIT and physical address
Message-Id: <32209efe0708131042p68748b3el85d3ec4d76864244@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hello,

Some help is needed with debugging of a hang.
A system hits BINIT once in a while and the processors are all
spinning on the address 0x00100002C00 and if the HT is off the address
becomes 0x0020000A80. This is a physical address captured on the bus
by analyser. How can this address be decoded to find out what are the
processors are spinning on?
Thanks,
--Natalie
