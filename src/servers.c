#ifdef HAVE_CONFIG_H
#include <config.h>
#endif

#ifdef HAVE_SYS_TYPES_H
#include <sys/types.h>
#endif

#ifdef HAVE_SYS_SOCKET_H
#include <sys/socket.h>
#endif

#include <sys/un.h>

#ifdef HAVE_UNISTD_H
#include <unistd.h>
#endif

#include <stdio.h>
#include "list.h"
#include "select.h"
#include "common.h"

#include "debug.h"

/*---------------------------------------------------------*/
static int
client_cb(int fd, int eventtypes, void *data)
{
char buf[1024];
struct select_node *active_fd;
int ret;

active_fd = data;

debug(5, "Client side callback\n");

if (eventtypes & WSD_FD_READ)
	{
	debug(5, "Client read ready\n");

	memset(buf, 0, sizeof(buf));
	ret = read(fd, &buf, sizeof(buf));
	if (ret == 0)
		{
		debug(5, "Client closed connection\n");
		close(fd);

		wsd_free_fd(active_fd);
		}
	else if (ret == -1)
		{
		debug(5, "Error reading client connection\n");
		close(fd);

		wsd_free_fd(active_fd);
		}
	else
		{
		/* Incoming data ignored (at least for now) */
		}
	}

if (eventtypes & WSD_FD_WRITE)
	{
	debug(5, "Client write ready\n");
	}

if (eventtypes & WSD_FD_EXCEPT)
	{
	debug(5, "Client exception ready\n");
	}

return 0;
}

/*---------------------------------------------------------*/
static int
listener_cb(int accept_fd, int eventtypes, void *data)
{
struct select_node *new_node;
int new_fd;

debug(5, "Accepting connection on: %d\n", accept_fd);

new_fd = accept(accept_fd, NULL, 0);
if (new_fd < 0)
	{
	perror("accept");
	return 1;
	}

debug(5, "Accepted new connection: %d\n", new_fd);

new_node = xmalloc(sizeof (struct select_node));

wsd_init_fd(new_node,				/* struct */
	new_fd,							/* file descriptor */
	WSD_FD_READ | WSD_FD_EXCEPT,	/* events */
	client_cb,						/* callback */
	1								/* broadcasts */
	);
	
wsd_add_fd(new_node);

return 0;
}

/*---------------------------------------------------------*/
int
init_local_listener()
{
struct sockaddr_un sun;
struct select_node *new_node;
int fd;
int ret;

fd = socket(PF_UNIX, SOCK_STREAM, 0);
if (fd < 0)
	{
	perror("socket");
	return -1;
	}

memset(&sun, 0, sizeof(sun));

sun.sun_family = AF_UNIX;
/* FIXME: Change to use program options unix_path */
/*        Also - better path name for easier access by mono, */
/*        python, etc. */
memcpy(sun.sun_path, "\0wsd", sizeof("\0wsd"));

ret = bind(fd, (struct sockaddr *) &sun, sizeof(sun));
if (ret < 0)
	{
	perror("bind");
	close(fd);
	return -1;
	}

ret = listen(fd, 5);
if (ret < 0)
	{
	perror("listen");
	close(fd);
	return -1;
	}

new_node = xmalloc(sizeof (struct select_node));

wsd_init_fd(new_node,				/* struct */
	fd,								/* file descriptor */
	WSD_FD_READ | WSD_FD_EXCEPT,	/* events */
	listener_cb,					/* callback */
	0								/* no broadcasts */
	);

wsd_add_fd(new_node);

return fd;
}