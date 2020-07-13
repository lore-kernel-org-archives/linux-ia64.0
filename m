From: "Alexander A. Klimov" <grandmaster@al2klimov.de>
Date: Mon, 13 Jul 2020 14:10:36 +0000
Subject: [PATCH] ia64: Replace HTTP links with HTTPS ones
Message-Id: <20200713141036.34841-1-grandmaster@al2klimov.de>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: tony.luck@intel.com, fenghua.yu@intel.com, corbet@lwn.net, linux-ia64@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: "Alexander A. Klimov" <grandmaster@al2klimov.de>

Rationale:
Reduces attack surface on kernel devs opening the links for MITM
as HTTPS traffic is much harder to manipulate.

Deterministic algorithm:
For each file:
  If not .svg:
    For each line:
      If doesn't contain `\bxmlns\b`:
        For each link, `\bhttp://[^# \t\r\n]*(?:\w|/)`:
	  If neither `\bgnu\.org/license`, nor `\bmozilla\.org/MPL\b`:
            If both the HTTP and HTTPS versions
            return 200 OK and serve the same content:
              Replace HTTP with HTTPS.

Signed-off-by: Alexander A. Klimov <grandmaster@al2klimov.de>
---
 Continuing my work started at 93431e0607e5.
 See also: git log --oneline '--author=Alexander A. Klimov <grandmaster@al2klimov.de>' v5.7..master
 (Actually letting a shell for loop submit all this stuff for me.)

 If there are any URLs to be removed completely or at least not just HTTPSified:
 Just clearly say so and I'll *undo my change*.
 See also: https://lkml.org/lkml/2020/6/27/64

 If there are any valid, but yet not changed URLs:
 See: https://lkml.org/lkml/2020/6/26/837

 If you apply the patch, please let me know.

 Sorry again to all maintainers who complained about subject lines.
 Now I realized that you want an actually perfect prefixes,
 not just subsystem ones.
 I tried my best...
 And yes, *I could* (at least half-)automate it.
 Impossible is nothing! :)


 Documentation/ia64/xen.rst | 2 +-
 arch/ia64/Kconfig          | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/Documentation/ia64/xen.rst b/Documentation/ia64/xen.rst
index 831339c74441..9da6abb02a2c 100644
--- a/Documentation/ia64/xen.rst
+++ b/Documentation/ia64/xen.rst
@@ -28,7 +28,7 @@ Getting and Building Xen and Dom0
 
 	# hg clone http://xenbits.xensource.com/ext/ia64/xen-unstable.hg
 	# cd xen-unstable.hg
-	# hg clone http://xenbits.xensource.com/ext/ia64/linux-2.6.18-xen.hg
+	# hg clone https://xenbits.xensource.com/ext/ia64/linux-2.6.18-xen.hg
 
  2. # make world
 
diff --git a/arch/ia64/Kconfig b/arch/ia64/Kconfig
index 1fa2fe2ef053..f21f121a8f42 100644
--- a/arch/ia64/Kconfig
+++ b/arch/ia64/Kconfig
@@ -223,7 +223,7 @@ config SMP
 	  will run faster if you say N here.
 
 	  See also the SMP-HOWTO available at
-	  <http://www.tldp.org/docs.html#howto>.
+	  <https://www.tldp.org/docs.html#howto>.
 
 	  If you don't know what to do here, say N.
 
-- 
2.27.0
