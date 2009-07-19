From: Julia Lawall <julia@diku.dk>
Date: Sun, 19 Jul 2009 15:29:37 +0000
Subject: [PATCH 7/10] drivers/serial: Move a dereference below a NULL test
Message-Id: <Pine.LNX.4.64.0907191729140.16542@ask.diku.dk>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: pfg@sgi.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org

From: Julia Lawall <julia@diku.dk>

If the NULL test is necessary, then the dereference should be moved below
the NULL test.

The semantic patch that makes this change is as follows:
(http://www.emn.fr/x-info/coccinelle/)

// <smpl>
@@
type T;
expression E,E1;
identifier i,fld;
statement S;
@@

- T i =3D E->fld;
+ T i;
  ... when !=3D E=E1
      when !=3D i
  BUG_ON (E =3D NULL);
+ i =3D E->fld;
// </smpl>

Signed-off-by: Julia Lawall <julia@diku.dk>

---
 drivers/serial/ioc3_serial.c |    3 ++-
 drivers/serial/ioc4_serial.c |    3 ++-
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/serial/ioc3_serial.c b/drivers/serial/ioc3_serial.c
index ae3699d..6d5c91b 100644
--- a/drivers/serial/ioc3_serial.c
+++ b/drivers/serial/ioc3_serial.c
@@ -1117,13 +1117,14 @@ static inline int do_read(struct uart_port *the_por=
t, char *buf, int len)
 	struct ioc3_port *port =3D get_ioc3_port(the_port);
 	struct ring *inring;
 	struct ring_entry *entry;
-	struct port_hooks *hooks =3D port->ip_hooks;
+	struct port_hooks *hooks;
 	int byte_num;
 	char *sc;
 	int loop_counter;
=20
 	BUG_ON(!(len >=3D 0));
 	BUG_ON(!port);
+	hooks =3D port->ip_hooks;
=20
 	/* There is a nasty timing issue in the IOC3. When the rx_timer
 	 * expires or the rx_high condition arises, we take an interrupt.
diff --git a/drivers/serial/ioc4_serial.c b/drivers/serial/ioc4_serial.c
index 6bab63c..aeca2f8 100644
--- a/drivers/serial/ioc4_serial.c
+++ b/drivers/serial/ioc4_serial.c
@@ -2067,13 +2067,14 @@ static inline int do_read(struct uart_port *the_por=
t, unsigned char *buf,
 	struct ioc4_port *port =3D get_ioc4_port(the_port, 0);
 	struct ring *inring;
 	struct ring_entry *entry;
-	struct hooks *hooks =3D port->ip_hooks;
+	struct hooks *hooks;
 	int byte_num;
 	char *sc;
 	int loop_counter;
=20
 	BUG_ON(!(len >=3D 0));
 	BUG_ON(!port);
+	hooks =3D port->ip_hooks;
=20
 	/* There is a nasty timing issue in the IOC4. When the rx_timer
 	 * expires or the rx_high condition arises, we take an interrupt.
