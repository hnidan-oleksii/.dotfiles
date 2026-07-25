/*
 * Strip ANSI SGR sequences (ESC [ [0-9;]* m) from a byte range, in place.
 *
 * Single memchr pass, no allocation. Links only memchr and memmove at GLIBC_2.2.5
 */
#include <string.h>

size_t ansi_strip(char *buf, size_t len)
{
	char *w = buf, *r = buf, *end = buf + len;

	while (r < end) {
		char *esc = memchr(r, 0x1b, (size_t)(end - r));
		if (!esc) {
			memmove(w, r, (size_t)(end - r));
			w += end - r;
			break;
		}

		if (w != r)
			memmove(w, r, (size_t)(esc - r));
		w += esc - r;
		r = esc;

		/* ESC [ [0-9;]* m - drop it, else keep the ESC and move on */
		char *p = esc + 1;
		if (p < end && *p == '[') {
			p++;
			while (p < end && ((*p >= '0' && *p <= '9') || *p == ';'))
				p++;
			if (p < end && *p == 'm') {
				r = p + 1;
				continue;
			}
		}
		*w++ = *r++;
	}

	return (size_t)(w - buf);
}
