using System.Collections;
using UnityEngine;

public class CoinSpawnerMonobehaviourUpdate : MonoBehaviour
{
    [SerializeField] Vector2 _area = new Vector2(28.445f, 16);
    [SerializeField] int _amount = 2;
    [SerializeField] int _spawnBatch = 64;
    [SerializeField] float _startDelay = 0;
    [SerializeField] GameObject _coin;
    [SerializeField] int _spawned = 0;

    void Start() => StartCoroutine(IterateSpawn());

    void SpawnCoin()
    {
        Instantiate(
            _coin,
            new Vector2(Random.Range(-_area.x/2, _area.x/2), Random.Range(-_area.y/2, _area.y/2)),
            Quaternion.identity
        );
    }

    IEnumerator IterateSpawn()
    {
        yield return new WaitForSecondsRealtime(_startDelay);
        for(int i = 0; i < _amount; i++)
        {
            SpawnCoin();
            _spawned = i+1;
            if(i % _spawnBatch == 0)
                yield return null;
        }
    }

    void OnDrawGizmos()
    {
        Gizmos.color = Color.red;
        Gizmos.DrawWireCube(Vector2.zero, _area);
    }
}
