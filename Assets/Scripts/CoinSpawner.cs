using System.Collections;
using UnityEngine;

public class CoinSpawner : MonoBehaviour
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
        GameObject spawnedCoin = Instantiate(_coin,
            new Vector2(Random.Range(-_area.x/2, _area.x/2), Random.Range(-_area.y/2, _area.y/2)),
            Quaternion.identity
        );
        Color color;
        color.r = Random.Range(0f, 1f); //Random Jump height
        color.g = Random.Range(0f, 1f); //Random flipbook offset
        color.b = Random.Range(0f, 1f); //Random Jump offset
        color.a = 1;

        spawnedCoin.transform.GetChild(1).GetChild(0).GetComponent<SpriteRenderer>().color = color;
        
        SpriteRenderer shadowSprite = spawnedCoin.transform.GetChild(0).GetComponent<SpriteRenderer>();
        color.a = shadowSprite.color.a;
        shadowSprite.color = color;

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
