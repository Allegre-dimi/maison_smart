# ndako

Une maison intelligente — désormais branchée sur le backend Django `smart_home`.

## Configuration du backend

Par défaut, l'application Flutter pointe vers `http://10.0.2.2:8000` (la
loopback hôte pour un émulateur Android). Pour cibler un autre serveur,
passez les variables `--dart-define` au lancement :

```bash
flutter run --dart-define=API_HOST=192.168.1.42 \
            --dart-define=API_PORT=8000 \
            --dart-define=API_SCHEME=http
```

- `API_HOST` (défaut `10.0.2.2`)
- `API_PORT` (défaut `8000`)
- `API_SCHEME` (défaut `http`, mettre `https` en production)

## Endpoints Django utilisés

| Domaine        | Endpoint                                                 |
|----------------|----------------------------------------------------------|
| Auth           | `POST /api/auth/jwt/login`, `refresh`, `logout`         |
| Profil         | `GET  /api/auth/me`                                      |
| Maisons        | `GET/POST/PUT/DELETE /api/maisons/`                      |
| Pièces         | `GET/POST/PUT/DELETE /api/pieces/`                       |
| Modules        | `GET/POST/PUT/DELETE /api/{compteurs|gaz|clims|eclairages|assistant_vocaux}/` |
| Commande module| `POST /api/{collection}/{id}/commande`                   |
| Assistant texte| `POST /api/user/assistant`                               |
| Invitations    | `POST /api/maisons/{id}/invitations`, `POST /api/invitations/accept`, `DELETE /api/invitations/{id}/` |

Les JWT (access + refresh) sont stockés via `shared_preferences` et injectés
automatiquement dans l'en-tête `Authorization: Bearer ...` par
`ApiClient`. Un refresh automatique est tenté en cas de réponse 401.

## Démarrage du backend Django

Côté `smart_home`, lancer :

```bash
python manage.py runserver 0.0.0.0:8000
```

(ou `daphne config.asgi:application -b 0.0.0.0 -p 8000` pour activer les
WebSocket.)
