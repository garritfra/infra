# Secrets

> TODO: Translate to english

Da wir die Secrets manuell anlegen muss immer angegeben werden, welcher Context
gemeint ist. Dies kann z.B. als Umgebungsvariable vorangestellt werden:

```bash
> CONTEXT=default make all
```

## Vorbereitung

Die einzurichtenden Secrets werden lokal in einem nicht unter Versionskontrolle liegenden Verzeichnis abgelegt.
Um diese Grundstruktur mit Beispiel-Dateien zu befüllen gibt es ein entsprechendes Target:

```bash
> CONTEXT=default make template
```

## Anwendung

Sobald alle Daten eingetragen sind können die Secrets im Cluster angelegt werden.

**ACHTUNG**: wenn nicht alle im Template vorgegebenen Daten angepasst wurden wird bei einem `make all` vermutlich
etwas zerstört.

```bash
> CONTEXT=default make all
```

Es gibt für jedes Secret ein einzelnes Target, um diese einzeln zu aktualisieren.

## Aktualisierung

**ACHTUNG**: Da wir die Secrets außerhalb von `kustomize` verwalten, um sie nicht in der
Kubernetes-Konfiguration mit einchecken zu müssen, bekommen die Anwendungen nicht mit,
wenn wir `Secret`s aktualisieren.

Deswegen ist nach jedem Austausch eines Secrets darauf zu achten dass die entsprechenden
Services (z.B. mit einem `kubectl rollout restart ...`) neu gestartet werden.

Ausnahme ist das allererste Deployment des Clusters, hier verhindern die noch fehlenden
Secrets den Start der einzelnen Komponenten so lange, bis sie angelegt sind. In diesem Fall
ist kein nachträglicher Neustart erforderlich.
