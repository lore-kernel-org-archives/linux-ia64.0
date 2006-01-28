From: Kyle McMartin <kyle@mcmartin.ca>
Date: Sat, 28 Jan 2006 05:02:52 +0000
Subject: Remove stale comment from ia64/Kconfig
Message-Id: <20060128050252.GB11815@quicksilver.road.mcmartin.ca>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Somehow I doubt this comment is meant to be here anymore... It's
been floating after the L1_CACHE_SHIFT entry since before Linux
moved to bitkeeper.

Signed-off-by: Kyle McMartin <kyle@parisc-linux.org>

diff --git a/arch/ia64/Kconfig b/arch/ia64/Kconfig
index 199eeaf..a1942f7 100644
--- a/arch/ia64/Kconfig
+++ b/arch/ia64/Kconfig
@@ -194,7 +194,6 @@ config IA64_L1_CACHE_SHIFT
 	default "7" if MCKINLEY
 	default "6" if ITANIUM
 
-# align cache-sensitive data to 64 bytes
 config IA64_CYCLONE
 	bool "Cyclone (EXA) Time Source support"
 	help
